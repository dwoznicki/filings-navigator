// NOTE: This file is a huge mess of functions. In reality, I'd want to organize it into separate
// modules (with imports/exports, if possible).

const Filings = (() => {
    // State
    const filerId = window.location.pathname.split("/").pop(); // get last token in path
    let currentFilingId;

    // Elements
    const filerHeader = document.getElementById("filer_header");
    const filingsList = document.getElementById("filings_list");
    const filingsItemTemplate = document.getElementById("filings_item_template");
    const filingDetailTaxYear = document.getElementById("filing_detail_tax_year");
    const filingDetailAmended = document.getElementById("filing_detail_amended");
    const filingDetailReturnTime = document.getElementById("filing_detail_return_time");
    const multipleFilings = document.getElementById("multiple_filings");

    // Functions
    const fetchFiler = async () => {
        if (filerId == null || Number.isNaN(parseInt(filerId))) {
            // Something strange has happened with the URL. Let's bail.
            throw new Error(`Invalid filer ID token in URL: ${filerId}`);
        }
        const params = new URLSearchParams({filer_id: filerId});
        const response = await fetch(`/api/v1/get_filers?${params}`);
        if (!response.ok) {
            throw new Error(`Error fetching filers from API. ${response}`);
        }
        return (await response.json())[0]; // should only be one result when filer_id is specified
    };

    const fetchFilings = async () => {
        if (filerId == null || Number.isNaN(parseInt(filerId))) {
            // Something strange has happened with the URL. Let's bail.
            throw new Error(`Invalid filer ID token in URL: ${filerId}`);
        }
        const params = new URLSearchParams({filer_id: filerId});
        const response = await fetch(`/api/v1/get_filings?${params}`);
        if (!response.ok) {
            throw new Error(`Error fetching filings from API. ${response}`);
        }
        return await response.json();
    };

    const getCurrentFilingId = () => currentFilingId;

    const setCurrentFilingId = (filingId) => currentFilingId = filingId;

    const updateFilerHeader = (filer) => {
        filerHeader.textContent = filer.name ?? "";
    };

    const groupFilingsByTaxYear = (filings) => {
        const groupedFilings = [];
        for (const filing of filings) {
            const taxYear = new Date(filing.tax_period).getFullYear();
            const existingGroup = groupedFilings.find(group => {
                return group.taxYear === taxYear;
            });
            if (existingGroup == null) {
                groupedFilings.push({
                    taxYear,
                    filings: [filing],
                });
            } else {
                existingGroup.filings.push(filing);
            }
        }
        return groupedFilings;
    };

    const appendFilingsToList = (groupedFilings) => {
        for (const group of groupedFilings) {
            const item = createFilingListItem(group);
            filingsList.append(item);
        }
    };

    const changeCurrentFiling = async (filingGroup) => {
        currentFilingId = filingGroup.filings[0].id;
        changeTaxYear(filingGroup.taxYear);
        changeFilingDetails(filingGroup.filings[0], filingGroup.taxYear, filingGroup.filings.length);
        changeMultipleFilings(filingGroup);
        await Awards.resetTable();
    };

    // Internal functions
    const createFilingListItem = (filingGroup) => {
        const taxYear = filingGroup.taxYear;
        const item = filingsItemTemplate.content.cloneNode(true).firstElementChild;
        const button = item.children[0];
        button.textContent = taxYear;
        button.dataset.taxYear = taxYear;
        button.disabled = false;
        button.addEventListener("click", () => {
            // Clicking the button for the current tax year should do nothing.
            if (button.disabled) {
                return;
            }
            changeCurrentFiling(filingGroup);
        });
        return item;
    };

    const changeTaxYear = (taxYear) => {
        const url = new URL(window.location.href);
        url.searchParams.set("tax_year", taxYear);
        window.history.replaceState(null, null, url);
        for (const button of filingsList.querySelectorAll(".tax_year_button")) {
            button.disabled = button.dataset.taxYear === String(taxYear);
        }
    };

    const changeFilingDetails = (filing, taxYear, numFilings) => {
        filingDetailTaxYear.textContent = taxYear;
        filingDetailAmended.textContent = numFilings > 1 ? "yes" : "no";
        filingDetailReturnTime.textContent = new Date(filing.return_time).toLocaleString();
    };

    const changeMultipleFilings = (filingGroup) => {
        if (filingGroup.filings.length > 1) {
            multipleFilings.querySelector(".num_filings").textContent = filingGroup.filings.length;
            multipleFilings.style.display = "block";
        } else {
            multipleFilings.style.display = "none";
        }
    };

    return {
        getCurrentFilingId,
        fetchFiler,
        fetchFilings,
        setCurrentFilingId,
        updateFilerHeader,
        groupFilingsByTaxYear,
        appendFilingsToList,
        changeCurrentFiling,
    };
})();

const Awards = (() => {
    // State
    let page = 1;
    let pageSize = 10;
    // NOTE: Right now, we only cache previous results by page. This could lead to extra data
    // fetching when filters are added and removed. To optimize, we'd probably want to cache by
    // filter state in addition to page.
    let awardsByPage = {}; 
    let awardsCount;

    // Elements
    const awardsTable = document.getElementById("awards_table");
    const awardsRowTemplate = document.getElementById("awards_row_template");
    const awardsFirstPageButton = document.getElementById("awards_first_page_button");
    const awardsPrevPageButton = document.getElementById("awards_prev_page_button");
    const awardsNextPageButton = document.getElementById("awards_next_page_button");
    const awardsLastPageButton = document.getElementById("awards_last_page_button");
    const awardsCurrentPage = document.getElementById("awards_current_page");
    const awardsFiltersToggler = document.getElementById("awards_filters_toggler");
    const awardsFiltersForm = document.getElementById("awards_filters_form");
    const nameFilter = document.getElementById("name_filter");
    const cityFilter = document.getElementById("city_filter");
    const stateCodeFilter = document.getElementById("state_code_filter");
    const zipCodeFilter = document.getElementById("zip_code_filter");
    const cashAmountOperatorFilter = document.getElementById("cash_amount_operator_filter");
    const cashAmountFilter = document.getElementById("cash_amount_filter");

    // Intialization
    awardsFirstPageButton.addEventListener("click", () => {
        gotoTablePage(1);
    });

    awardsPrevPageButton.addEventListener("click", () => {
        // Extra security to make sure we don't end up with an invalid page.
        if (page <= 1) {
            return;
        }
        gotoTablePage(page - 1);
    });

    awardsNextPageButton.addEventListener("click", () => {
        // Extra security to make sure we don't end up with an invalid page.
        const lastPage = Math.ceil(awardsCount / pageSize);
        if (page >= lastPage) {
            return;
        }
        gotoTablePage(page + 1);
    });

    awardsLastPageButton.addEventListener("click", () => {
        const lastPage = Math.ceil(awardsCount / pageSize);
        gotoTablePage(lastPage);
    });

    awardsFiltersForm.addEventListener("submit", (event) => {
        event.preventDefault();
        resetTable();
    });

    // Fuctions
    const fetchAwards = async (filingId, filters, page) => {
        const params = new URLSearchParams(filters);
        params.set("filing_id", filingId);
        params.set("page", page);
        const response = await fetch(`/api/v1/get_awards?${params}`);
        if (!response.ok) {
            throw new Error(`Error fetching awards from API. ${response}`);
        }
        return await response.json();
    };

    const fetchAwardsCount = async (filingId, filters) => {
        const params = new URLSearchParams(filters);
        params.set("filing_id", filingId);
        const response = await fetch(`/api/v1/count_awards?${params}`);
        if (!response.ok) {
            throw new Error(`Error fetching awards count from API. ${response}`);
        }
        return await response.json();
    };

    const resetTable = async () => {
        const filters = getFiltersFromDom();
        const awards = await fetchAwards(Filings.getCurrentFilingId(), filters, 1);
        awardsByPage = {
            1: awards,
        };
        awardsCount = await fetchAwardsCount(Filings.getCurrentFilingId(), filters);
        page = 1;
        updateAwardsTableRows();
        updateAwardsPaginationButtons();
        updateAwardsCurrentPageInfo();
        changeQueryString(filters, 1);
    };

    const gotoTablePage = async (newPage) => {
        const filters = getFiltersFromDom();
        let awards = awardsByPage[newPage];
        if (awards == null) {
            awards = await fetchAwards(Filings.getCurrentFilingId(), filters, newPage);
        }
        awardsByPage[newPage] = awards;
        page = newPage;
        updateAwardsTableRows();
        updateAwardsPaginationButtons();
        updateAwardsCurrentPageInfo();
        changeQueryString(filters, 1);
    };

    const initializeFiltersFromQueryString = () => {
        const params = new URLSearchParams(window.location.search);
        let filterFound = false;
        if (params.has("recipient_name")) {
            nameFilter.value = params.get("recipient_name");
            filterFound = true;
        }
        if (params.has("city")) {
            cityFilter.value = params.get("city");
            filterFound = true;
        }
        if (params.has("state_code")) {
            stateCodeFilter.value = params.get("state_code");
            filterFound = true;
        }
        if (params.has("zip_code")) {
            zipCodeFilter.value = params.get("zip_code");
            filterFound = true;
        }
        if (params.has("cash_amount")) {
            cashAmountOperatorFilter.value = params.get("cash_amount_operator");
            cashAmountFilter.value = params.get("cash_amount");
            filterFound = true;
        }
        if (filterFound) {
            awardsFiltersToggler.open = true;
        }
    };

    // Internal functions
    const updateAwardsTableRows = () => {
        const tableRows = awardsTable.children[1].querySelectorAll("tr");
        for (const row of tableRows) {
            row.remove();
        }
        const awards = awardsByPage[page];
        if (awards == null) {
            return;
        }
        for (const award of awards) {
            const row = awardsRowTemplate.content.cloneNode(true).firstElementChild;
            row.children[0].textContent = award.name;
            row.children[1].querySelector(".recipient_address_first_line").textContent = award.address_line1 || "";
            let recipientAddressLine2Tokens = [];
            if (award.city != null) {
                recipientAddressLine2Tokens.push(award.city);
            }
            if (award.state_code != null) {
                recipientAddressLine2Tokens.push(award.state_code);
            }
            if (award.zip_code != null) {
                recipientAddressLine2Tokens.push(award.zip_code);
            }
            row.children[1].querySelector(".recipient_address_second_line").textContent = recipientAddressLine2Tokens.join(", ");
            row.children[2].textContent = "$" + award.cash_amount.toLocaleString();
            row.children[3].textContent = award.purpose ?? "";
            awardsTable.children[1].append(row);
        }
    };

    const updateAwardsPaginationButtons = () => {
        if (page === 1) {
            awardsFirstPageButton.disabled = true;
            awardsPrevPageButton.disabled = true;
        } else {
            awardsFirstPageButton.disabled = false;
            awardsPrevPageButton.disabled = false;
        }
        if (page === Math.ceil(awardsCount / pageSize)) {
            awardsNextPageButton.disabled = true;
            awardsLastPageButton.disabled = true;
        } else {
            awardsNextPageButton.disabled = false;
            awardsLastPageButton.disabled = false;
        }
    };

    const updateAwardsCurrentPageInfo = () => {
        let startNum = ((page - 1) * pageSize) + 1;
        let endNum = Math.min(startNum + pageSize - 1, awardsCount);
        awardsCurrentPage.textContent = `Showing ${startNum} - ${endNum} of ${awardsCount}`;
    };

    const getFiltersFromDom = () => {
        const filters = {};
        if (nameFilter.value) {
            filters.recipient_name = nameFilter.value;
        }
        if (cityFilter.value) {
            filters.city = cityFilter.value;
        }
        if (stateCodeFilter.value) {
            filters.state_code = stateCodeFilter.value;
        }
        if (zipCodeFilter.value) {
            filters.zip_code = zipCodeFilter.value;
        }
        if (cashAmountFilter.value) {
            filters.cash_amount_operator = cashAmountOperatorFilter.value || "equal";
            filters.cash_amount = cashAmountFilter.value;
        }
        return filters;
    };

    const changeQueryString = (filters, page) => {
        const url = new URL(window.location.href);
        if (filters.recipient_name != null) {
            url.searchParams.set("recipient_name", filters.recipient_name);
        } else {
            url.searchParams.delete("recipient_name");
        }
        if (filters.city != null) {
            url.searchParams.set("city", filters.city);
        } else {
            url.searchParams.delete("city");
        }
        if (filters.state_code != null) {
            url.searchParams.set("state_code", filters.state_code);
        } else {
            url.searchParams.delete("state_code");
        }
        if (filters.zip_code != null) {
            url.searchParams.set("zip_code", filters.zip_code);
        } else {
            url.searchParams.delete("zip_code");
        }
        if (filters.cash_amount != null) {
            url.searchParams.set("cash_amount_operator", filters.cash_amount_operator);
            url.searchParams.set("cash_amount", filters.cash_amount);
        } else {
            url.searchParams.delete("cash_amount_operator");
            url.searchParams.delete("cash_amount");
        }
        url.searchParams.set("page", page);
        window.history.replaceState(null, null, url);
    };

    return {
        fetchAwards,
        fetchAwardsCount,
        resetTable,
        gotoTablePage,
        initializeFiltersFromQueryString,
    };
})();

// -------------------------------------------------------------------------------------------------
// Pagination
const main = async () => {
    Awards.initializeFiltersFromQueryString();
    // Start our fetches in parallel.
    const filerPromise = Filings.fetchFiler();
    const filingsPromise = Filings.fetchFilings();

    const filer = await filerPromise;
    Filings.updateFilerHeader(filer);

    const filings = await filingsPromise;
    // First, filter down to one filing per tax period. The results from the server should already
    // be ordered, so we should only need to group them here.
    const groupedFilings = Filings.groupFilingsByTaxYear(filings);
    Filings.appendFilingsToList(groupedFilings);
    // Set the currently viewed filing based on tax year in query string, defaulting to latest if
    // missing.
    const taxYearFromUrl = new URLSearchParams(window.location.search).get("tax_year");
    let viewGroupedFiling;
    for (const group of groupedFilings) {
        if (String(group.taxYear) === taxYearFromUrl) {
            viewGroupedFiling = group;
            break;
        }
    }
    if (viewGroupedFiling == null) {
        viewGroupedFiling = groupedFilings[0];
    }
    await Filings.changeCurrentFiling(viewGroupedFiling);
};
main();
