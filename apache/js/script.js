// $_POST PopUp Fix
if(window.history.replaceState) {
    window.history.replaceState( null, null, window.location.href );
}
// Save Status
function check(text) {
    var statusSpan = document.getElementById("saveStatus");
    const fileValue = document.getElementsByTagName("code-input")[1].value;
    if(text != fileValue) {
        statusSpan.classList.remove("saved");
        statusSpan.classList.add("modified");
    }
    else {
        statusSpan.classList.remove("modified");
        statusSpan.classList.add("saved");
    }
}
// Scroll To The Bottom In The Response Area
window.addEventListener('load', (event) => {
    document.getElementById('area').scrollTop = document.getElementById('area').scrollHeight;
});