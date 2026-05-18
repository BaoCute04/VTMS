(function () {
    const page = document.querySelector(".spectator-standings");
    if (!page) return;

    const UI = window.SpectatorUI;
    const tbody = document.getElementById("tbody");
    const empty = document.getElementById("empty");
    const table = document.getElementById("standingTable");
    const sub = document.getElementById("standingSub");
    const api = page.dataset.standingsApi;

    async function load() {
        try {
            const payload = await UI.requestJson(api);
            const standings = Array.isArray(payload.data) ? payload.data : [];
            const latest = standings[0];

            if (!latest) {
                empty.classList.remove("hidden");
                table.classList.add("hidden");
                tbody.innerHTML = "";
                return;
            }

            const detailPayload = await UI.requestJson(`${api}/${encodeURIComponent(latest.idbangxephang)}`);
            const standing = detailPayload.data || latest;
            const rows = Array.isArray(detailPayload.rows) ? detailPayload.rows : [];
            sub.textContent = `${standing.tenbangxephang || "Bảng xếp hạng"} • ${standing.tengiaidau || ""}`;
            empty.classList.toggle("hidden", rows.length > 0);
            table.classList.toggle("hidden", rows.length === 0);
            tbody.innerHTML = rows.map((row) => `
                <tr>
                    <td class="rank">${UI.escapeHtml(row.hang || "-")}</td>
                    <td>${UI.escapeHtml(row.tendoibong || "-")}</td>
                    <td>${UI.escapeHtml(row.sotran ?? 0)}</td>
                    <td>${UI.escapeHtml(row.thang ?? 0)}</td>
                    <td>${UI.escapeHtml(row.thua ?? 0)}</td>
                    <td>${UI.escapeHtml(row.hieusoset ?? ((row.sosetthang || 0) - (row.sosetthua || 0)))}</td>
                    <td class="points">${UI.escapeHtml(row.diem ?? 0)}</td>
                </tr>
            `).join("");
        } catch (error) {
            tbody.innerHTML = `<tr><td colspan="7" class="empty">${UI.escapeHtml(error.message)}</td></tr>`;
        }
    }

    load();
})();
