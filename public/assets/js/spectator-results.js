(function () {
    const page = document.querySelector(".spectator-results");
    if (!page) return;

    const UI = window.SpectatorUI;
    const tbody = document.getElementById("tbody");
    const empty = document.getElementById("empty");
    const table = document.getElementById("resultTable");

    async function load() {
        try {
            const payload = await UI.requestJson(page.dataset.resultsApi);
            const results = Array.isArray(payload.data) ? payload.data : [];
            empty.classList.toggle("hidden", results.length > 0);
            table.classList.toggle("hidden", results.length === 0);
            tbody.innerHTML = results.map((item) => `
                <tr>
                    <td>${UI.escapeHtml(item.tengiaidau || "-")}</td>
                    <td>${UI.escapeHtml(item.vongdau || item.tenbang || "-")}</td>
                    <td>${UI.escapeHtml(item.doi1 || "-")} vs ${UI.escapeHtml(item.doi2 || "-")}</td>
                    <td class="score">${UI.escapeHtml(UI.score(item))}</td>
                    <td>${UI.escapeHtml(UI.formatDateTime(item.thoigianbatdau || item.ngaycongbo))}</td>
                </tr>
            `).join("");
        } catch (error) {
            tbody.innerHTML = `<tr><td colspan="5" class="empty">${UI.escapeHtml(error.message)}</td></tr>`;
        }
    }

    load();
})();
