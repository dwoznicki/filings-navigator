const filerId = window.location.pathname.split("/").pop(); // get last token in path
const filerHeader = document.getElementById("filer_header");
const filingsList = document.getElementById("filings_list");
const filingsItemTemplate = document.getElementById("filings_item_template");

let currentTaxYear = null;

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

const updateFilerHeader = (filer) => {
    filerHeader.textContent = `Filer ${filer.name ?? ""}`;
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

const groupFilingsByTaxPeriod = (filings) => {
    const groupedFilings = [];
    for (const filing of filings) {
        const existingGroup = groupedFilings.find(group => {
            return group[0].tax_period === filing.tax_period;
        });
        if (existingGroup == null) {
            groupedFilings.push([filing]);
        } else {
            existingGroup.push(filing);
        }
    }
    return groupedFilings;
};

const loadFilingDataForTaxYear = (taxYear) => {
};

const createFilingListItem = (filingGroup) => {
    const filing = filingGroup[0];
    const isPlural = filingGroup.length > 0;
    const taxYear = new Date(filing.tax_period).getFullYear();
    const item = filingsItemTemplate.content.cloneNode(true).firstElementChild;
    const button = item.children[0];
    button.textContent = `${taxYear} (${filingGroup.length} ${isPlural ? "filings" : "filing"})`;
    button.dataset.taxYear = taxYear;
    button.addEventListener("click", () => {
        loadFilingDataForTaxYear(button.dataset.taxYear);
    });
    return item;
};

const appendFilingsToList = (groupedFilings) => {
    for (const group of groupedFilings) {
        const item = createFilingListItem(group);
        filingsList.append(item);
    }
};

const main = async () => {
    // Start our fetches in parallel.
    const filerPromise = fetchFiler();
    const filingsPromise = fetchFilings();

    const filer = await filerPromise;
    updateFilerHeader(filer);

    const filings = await filingsPromise;
    // First, filter down to one filing per tax period. The results from the server should already
    // be ordered, so we should only need to group them here.
    const groupedFilings = groupFilingsByTaxPeriod(filings);
    appendFilingsToList(groupedFilings);
};
main();
