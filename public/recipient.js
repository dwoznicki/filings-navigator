const recipientId = window.location.pathname.split("/").pop(); // get last token in path

const recipientHeader = document.getElementById("recipient_header");
const recipientDetailEin = document.getElementById("recipient_detail_ein");
const recipientDetailAddress = document.getElementById("recipient_detail_address");

const fetchRecipient = async () => {
    if (recipientId == null || Number.isNaN(parseInt(recipientId))) {
        // Something strange has happened with the URL. Let's bail.
        throw new Error(`Invalid recipient ID token in URL: ${recipientId}`);
    }
    const params = new URLSearchParams({recipient_id: recipientId});
    const response = await fetch(`/api/v1/get_recipients?${params}`);
    if (!response.ok) {
        throw new Error(`Error fetching recipients from API. ${response}`);
    }
    return (await response.json())[0]; // should only be one result when filer_id is specified
};

const updateRecipientInfo = (recipient) => {
    recipientHeader.textContent = recipient.name;
    recipientDetailEin.textContent = recipient.ein || "none";
    recipientDetailAddress.children[0].textContent = recipient.address_line1 || "";
    let recipientAddressLine2Tokens = [];
    if (recipient.city != null) {
        recipientAddressLine2Tokens.push(recipient.city);
    }
    if (recipient.state_code != null) {
        recipientAddressLine2Tokens.push(recipient.state_code);
    }
    if (recipient.zip_code != null) {
        recipientAddressLine2Tokens.push(recipient.zip_code);
    }
    recipientDetailAddress.children[1].textContent = recipientAddressLine2Tokens.join(", ");
};

const main = async () => {
    const recipient = await fetchRecipient();
    updateRecipientInfo(recipient);
};
main();
