(function () {
    const page = document.querySelector(".spectator-schedule");
    if (!page) return;

    const UI = window.SpectatorUI;
    const tbody = document.getElementById("tbody");
    const empty = document.getElementById("empty");
    const table = document.getElementById("scheduleTable");

    async function load() {
        try {
            const payload = await UI.requestJson(page.dataset.scheduleApi);
            const schedules = Array.isArray(payload.data) ? payload.data : [];
            empty.classList.toggle("hidden", schedules.length > 0);
            table.classList.toggle("hidden", schedules.length === 0);
            tbody.innerHTML = schedules.map((item) => `
                <tr>
                    <td>${UI.escapeHtml(UI.formatDateTime(item.thoigianbatdau))}</td>
                    <td>${UI.escapeHtml(item.tengiaidau || "-")}</td>
                    <td>${UI.escapeHtml(item.doi1 || "-")} vs ${UI.escapeHtml(item.doi2 || "-")}</td>
                    <td>${UI.escapeHtml(item.tensandau || item.sandau_diachi || "-")}</td>
                    <td>${UI.escapeHtml(item.vongdau || item.tenbang || "-")}</td>
                </tr>
            `).join("");
        } catch (error) {
            tbody.innerHTML = `<tr><td colspan="5" class="empty">${UI.escapeHtml(error.message)}</td></tr>`;
        }
    }

    load();
})();
