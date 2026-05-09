(function () {
    const root = document.querySelector(".coach-lineup-editor");
    if (!root) return;

    const ui = window.CoachUI;
    const teamsApi = root.dataset.teamsApi || "/api/coach/teams";
    const registrationsApi = root.dataset.registrationsApi || "/api/coach/tournament-registrations";

    const teamSelect = document.getElementById("teamSelect");
    const tournamentSelect = document.getElementById("tournamentSelect");
    const lineupSelect = document.getElementById("lineupSelect");
    const playerList = document.getElementById("playerList");
    const lineupBody = document.getElementById("lineupBody");
    const alertBox = document.getElementById("alert");
    const pageMessage = document.getElementById("pageMessage");

    let teams = [];
    let registrations = [];
    let members = [];
    let lineups = [];
    let lineupDetails = [];
    let selected = [];

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

    function renderMembers() {
        const active = members.filter((member) => member.trangthaithanhvien === "DANG_THAM_GIA");
        if (active.length === 0) {
            playerList.innerHTML = '<li class="empty">Không có VĐV đang tham gia.</li>';
            return;
        }

        playerList.innerHTML = active.map((member) => `
            <li><button class="btn" type="button" data-id="${ui.escapeHtml(member.idvandongvien)}">${ui.escapeHtml(member.hoten)} - ${ui.escapeHtml(member.vitri || "")}</button></li>
        `).join("");
    }

    function renderSelected() {
        if (selected.length === 0) {
            lineupBody.innerHTML = '<tr><td colspan="4" class="empty">Chưa chọn VĐV.</td></tr>';
            return;
        }

        lineupBody.innerHTML = selected.map((item, index) => `
            <tr>
                <td>${index + 1}</td>
                <td>${ui.escapeHtml(item.hoten)}</td>
                <td>
                    <select data-id="${ui.escapeHtml(item.idvandongvien)}" data-field="position">
                        ${["CHU_CONG", "PHU_CONG", "CHUYEN_HAI", "DOI_CHUYEN", "LIBERO", "DOI_TRU"].map((position) => (
                            `<option value="${position}" ${position === item.vitri ? "selected" : ""}>${position}</option>`
                        )).join("")}
                    </select>
                </td>
                <td><button class="btn danger" type="button" data-remove="${ui.escapeHtml(item.idvandongvien)}">Xóa</button></td>
            </tr>
        `).join("");
    }

    function fillLineups() {
        let html = '<option value="">Tạo đội hình mới</option>';
        html += lineups.map((lineup) => `<option value="${ui.escapeHtml(lineup.iddoihinh)}">${ui.escapeHtml(lineup.tendoihinh)}</option>`).join("");
        lineupSelect.innerHTML = html;
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

    async function loadTeamData() {
        if (!teamSelect.value) return;
        const memberPayload = await ui.requestJson(`${teamsApi}/${teamSelect.value}/members`);
        members = memberPayload.data || [];
        renderMembers();
    }

    async function loadLineups() {
        lineups = [];
        lineupDetails = [];
        fillLineups();
        if (!teamSelect.value || !tournamentSelect.value) return;
        const payload = await ui.requestJson(`${teamsApi}/${teamSelect.value}/lineups?tournament_id=${encodeURIComponent(tournamentSelect.value)}`);
        lineups = payload.data || [];
        lineupDetails = payload.details || [];
        fillLineups();
    }

    function hydrateExistingLineup() {
        const lineup = lineups.find((item) => String(item.iddoihinh) === String(lineupSelect.value));
        if (!lineup) {
            document.getElementById("lineupName").value = "";
            document.getElementById("lineupStatus").value = "BAN_NHAP";
            selected = [];
            renderSelected();
            return;
        }

        document.getElementById("lineupName").value = lineup.tendoihinh || "";
        document.getElementById("lineupStatus").value = lineup.trangthai || "BAN_NHAP";
        selected = lineupDetails
            .filter((detail) => String(detail.iddoihinh) === String(lineup.iddoihinh))
            .map((detail) => ({
                idvandongvien: Number(detail.idvandongvien),
                hoten: detail.hoten,
                vitri: detail.vitri,
            }));
        renderSelected();
    }

    playerList.addEventListener("click", (event) => {
        const button = event.target.closest("button[data-id]");
        if (!button) return;
        const member = members.find((item) => String(item.idvandongvien) === String(button.dataset.id));
        if (!member || selected.some((item) => Number(item.idvandongvien) === Number(member.idvandongvien))) return;
        selected.push({ idvandongvien: Number(member.idvandongvien), hoten: member.hoten, vitri: member.vitri || "CHU_CONG" });
        renderSelected();
    });

    lineupBody.addEventListener("click", (event) => {
        const button = event.target.closest("button[data-remove]");
        if (!button) return;
        selected = selected.filter((item) => String(item.idvandongvien) !== String(button.dataset.remove));
        renderSelected();
    });

    lineupBody.addEventListener("change", (event) => {
        const select = event.target.closest("select[data-field='position']");
        if (!select) return;
        const item = selected.find((row) => String(row.idvandongvien) === String(select.dataset.id));
        if (item) item.vitri = select.value;
    });

    async function refreshAfterSelect() {
        ui.hideAlert(alertBox);
        refreshTournamentSelect();
        selected = [];
        renderSelected();
        await loadTeamData();
        await loadLineups();
    }

    teamSelect.addEventListener("change", () => refreshAfterSelect().catch((error) => ui.show(pageMessage, ui.errorsText(error), true)));
    tournamentSelect.addEventListener("change", () => loadLineups().then(hydrateExistingLineup).catch((error) => ui.show(pageMessage, ui.errorsText(error), true)));
    lineupSelect.addEventListener("change", hydrateExistingLineup);

    document.getElementById("btnSave").addEventListener("click", async () => {
        ui.hideAlert(alertBox);
        if (!teamSelect.value || !tournamentSelect.value || !document.getElementById("lineupName").value.trim()) {
            ui.showAlert(alertBox, "Vui lòng chọn đội, giải đấu và nhập tên đội hình.");
            return;
        }
        if (selected.length === 0) {
            ui.showAlert(alertBox, "Vui lòng chọn ít nhất 1 VĐV.");
            return;
        }

        const payload = {
            idgiaidau: tournamentSelect.value,
            tendoihinh: document.getElementById("lineupName").value.trim(),
            trangthai: document.getElementById("lineupStatus").value,
            details: selected.map((item, index) => ({
                idvandongvien: item.idvandongvien,
                vitri: item.vitri,
                sothutu: index + 1,
            })),
        };

        try {
            const editingId = lineupSelect.value;
            const result = await ui.requestJson(editingId ? `${teamsApi.replace(/\/teams$/, "/lineups")}/${editingId}` : `${teamsApi}/${teamSelect.value}/lineups`, {
                method: editingId ? "PUT" : "POST",
                body: JSON.stringify(payload),
            });
            ui.show(pageMessage, result.message || "Lưu đội hình thành công.");
            await loadLineups();
        } catch (error) {
            ui.showAlert(alertBox, ui.errorsText(error));
        }
    });

    loadBase()
        .then(refreshAfterSelect)
        .catch((error) => ui.show(pageMessage, ui.errorsText(error), true));
})();
