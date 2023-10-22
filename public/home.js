// NOTE: Async/await has pretty good browser support (>95%), but I might go with promises in
// production, provided we weren't transpiling our JavaScript files.
// https://caniuse.com/async-functions

const filersList = document.getElementById("filers_list");
const filerItemTemplate = document.getElementById("filer_item_template");

const fetchFilers = async () => {
    const response = await fetch("/api/v1/get_filers");
    if (!response.ok) {
        throw new Error(`Error fetching filers from API. ${response}`);
    }
    return await response.json();
};

const createFilterListItem = (filer) => {
    const item = filerItemTemplate.content.cloneNode(true).firstElementChild;
    item.children[0].href = `/filer/${filer.id}`;
    item.children[0].textContent = filer.name;
    return item;
};

const appendFilersToList = (filers) => {
    for (const filer of filers) {
        const filerItem = createFilterListItem(filer);
        filersList.append(filerItem);
    }
};

const main = async () => {
    const filers = await fetchFilers();
    appendFilersToList(filers);
};
main();
