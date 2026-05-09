(function () {
    const root = document.querySelector(".coach-lineup");
    if (!root) return;

    const ui = window.CoachUI;
    const teamsApi = root.dataset.teamsApi || "/api/coach/teams";
    const registrationsApi = root.dataset.registrationsApi || "/api/coach/tournament-registrations";
    const teamSelect = document.getElementById("teamSelect");
    const tournamentSelect = document.getElementById("tournamentSelect");
    const container = document.getElementById("lineupInfo");
    const pageMessage = document.getElementById("pageMessage");

    let teams = [];
    let registrations = [];

    function tournamentOptionsForTeam(teamId) {
        const seen = new Set();
        return registrations
            .filter((registration) => String(registration.iddoibong) === String(teamId) && registration.trangthai === "DA_DUYET")
            .filter((registration) => {
                if (seen.has(registration.idgiaidau)) return false;
                seen.add(registration.idgiaidau);
                return true;
            })
            .map((registration) => ({ idgiaidau: registration.idgiaidau, tengiaidau: registration.tengiaidau }));
    }

    function refreshTournamentSelect() {
        ui.fillSelect(tournamentSelect, tournamentOptionsForTeam(teamSelect.value), "idgiaidau", "tengiaidau", "Chọn giải đấu");
    }

    async function loadBase() {
        const [teamsPayload, registrationsPayload] = await Promise.all([
            ui.requestJson(teamsApi),
            ui.requestJson(registrationsApi),
        ]);
        teams = teamsPayload.data || [];
        registrations = registrationsPayload.data || [];
        ui.fillSelect(teamSelect, teams, "iddoibong", "tendoibong", "Chọn đội bóng");
        refreshTournamentSelect();
    }

    async function loadLineups() {
        if (!teamSelect.value || !tournamentSelect.value) {
            container.innerHTML = '<p class="empty">Chọn đội và giải đấu để xem đội hình.</p>';
            return;
        }

        const payload = await ui.requestJson(`${teamsApi}/${teamSelect.value}/lineups?tournament_id=${encodeURIComponent(tournamentSelect.value)}`);
        const lineups = payload.data || [];
        const details = payload.details || [];

        if (lineups.length === 0) {
            container.innerHTML = '<p class="empty">Chưa có đội hình được tạo cho giải này.</p>';
            return;
        }

        container.innerHTML = lineups.map((lineup) => {
            const [badgeClass, label] = ui.badge(lineup.trangthai);
            const items = details.filter((detail) => String(detail.iddoihinh) === String(lineup.iddoihinh));
            return `
                <article class="lineup-block">
                    <h3>${ui.escapeHtml(lineup.tendoihinh)} <span class="badge ${badgeClass}">${ui.escapeHtml(label)}</span></h3>
                    <table class="coach-table compact">
                        <thead><tr><th>STT</th><th>VĐV</th><th>Vị trí</th><th>Ghi chú</th></tr></thead>
                        <tbody>
                            ${items.map((item) => `
                                <tr>
                                    <td>${ui.escapeHtml(item.sothutu)}</td>
                                    <td>${ui.escapeHtml(item.hoten)}</td>
                                    <td>${ui.escapeHtml(item.vitri)}</td>
                                    <td>${ui.escapeHtml(item.ghichu || "")}</td>
                                </tr>
                            `).join("") || '<tr><td colspan="4" class="empty">Không có VĐV.</td></tr>'}
                        </tbody>
                    </table>
                </article>
            `;
        }).join("");
    }

    teamSelect.addEventListener("change", () => {
        refreshTournamentSelect();
        loadLineups().catch((error) => ui.show(pageMessage, ui.errorsText(error), true));
    });
    tournamentSelect.addEventListener("change", () => loadLineups().catch((error) => ui.show(pageMessage, ui.errorsText(error), true)));
    document.getElementById("btnRefresh").addEventListener("click", async () => {
        try {
            await loadBase();
            await loadLineups();
        } catch (error) {
            ui.show(pageMessage, ui.errorsText(error), true);
        }
    });

    loadBase()
        .then(loadLineups)
        .catch((error) => ui.show(pageMessage, ui.errorsText(error), true));
})();
