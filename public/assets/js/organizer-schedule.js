(function () {
    const root = document.querySelector(".organizer-schedule");

    if (!root) {
        return;
    }

    const scheduleTournamentsApi = root.dataset.scheduleTournamentsApi || "/api/organizer/schedules/tournaments";
    const tournamentApiBase = root.dataset.tournamentApiBase || "/api/organizer/tournaments";

    const tQ = document.getElementById("t_q");
    const tRefresh = document.getElementById("t_refresh");
    const tList = document.getElementById("t_list");

    const tourName = document.getElementById("tour_name");
    const tourSub = document.getElementById("tour_sub");
    const btnAddGroup = document.getElementById("btnAddGroup");
    const btnAddMatch = document.getElementById("btnAddMatch");

    const gQ = document.getElementById("g_q");
    const gTbody = document.getElementById("g_tbody");
    const mGroup = document.getElementById("m_group");
    const mTbody = document.getElementById("m_tbody");
    const pageAlert = document.getElementById("page_alert");

    const groupModal = document.getElementById("groupModal");
    const gmTitle = document.getElementById("gm_title");
    const gmClose = document.getElementById("gm_close");
    const gmCancel = document.getElementById("gm_cancel");
    const gmSave = document.getElementById("gm_save");
    const gmDelete = document.getElementById("gm_delete");
    const gmAlert = document.getElementById("gm_alert");
    const gmName = document.getElementById("gm_name");
    const gmStatus = document.getElementById("gm_status");
    const gmTeams = document.getElementById("gm_teams");
    const gmDesc = document.getElementById("gm_desc");

    const matchModal = document.getElementById("matchModal");
    const mmTitle = document.getElementById("mm_title");
    const mmClose = document.getElementById("mm_close");
    const mmCancel = document.getElementById("mm_cancel");
    const mmSave = document.getElementById("mm_save");
    const mmDelete = document.getElementById("mm_delete");
    const mmAlert = document.getElementById("mm_alert");
    const mmGroup = document.getElementById("mm_group");
    const mmRound = document.getElementById("mm_round");
    const mmTeam1 = document.getElementById("mm_team1");
    const mmTeam2 = document.getElementById("mm_team2");
    const mmVenue = document.getElementById("mm_venue");
    const mmStatus = document.getElementById("mm_status");
    const mmStart = document.getElementById("mm_start");
    const mmEnd = document.getElementById("mm_end");

    const GROUP_STATUSES = {
        HOAT_DONG: ["ok", "Hoạt động"],
        DA_KHOA: ["gray", "Đã khóa"],
        DA_XOA: ["lock", "Đã xóa"],
    };

    const MATCH_STATUSES = {
        CHUA_DIEN_RA: ["gray", "Chưa diễn ra"],
        SAP_DIEN_RA: ["wait", "Sắp diễn ra"],
        DANG_DIEN_RA: ["wait", "Đang diễn ra"],
        TAM_DUNG: ["wait", "Tạm dừng"],
        DA_KET_THUC: ["ok", "Đã kết thúc"],
        DA_HUY: ["lock", "Đã hủy"],
    };

    let tournaments = [];
    let selectedTournament = null;
    let groups = [];
    let matches = [];
    let teams = [];
    let venues = [];
    let editingGroupId = null;
    let editingMatchId = null;

    function escapeHtml(value) {
        return String(value ?? "")
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;");
    }

    function showMessage(message, isError = false) {
        pageAlert.textContent = message || "";
        pageAlert.classList.toggle("is-error", isError);
    }

    function showModalError(element, message) {
        element.textContent = message || "Yêu cầu không thành công.";
        element.classList.remove("hidden");
    }

    function hideModalError(element) {
        element.textContent = "";
        element.classList.add("hidden");
    }

    async function requestJson(url, options = {}) {
        const response = await fetch(url, {
            headers: {
                Accept: "application/json",
                "Content-Type": "application/json",
                ...(options.headers || {}),
            },
            credentials: "same-origin",
            ...options,
        });
        const payload = await response.json().catch(() => ({}));

        if (!response.ok || payload.success === false) {
            const error = new Error(payload.message || "Yêu cầu không thành công.");
            error.status = response.status;
            error.payload = payload;
            throw error;
        }

        return payload;
    }

    function urlFrom(path, params = null) {
        const url = new URL(path, window.location.origin);

        if (params) {
            Object.entries(params).forEach(([key, value]) => {
                if (value !== null && value !== undefined && String(value).trim() !== "") {
                    url.searchParams.set(key, value);
                }
            });
        }

        return url.toString();
    }

    function tournamentUrl(tournamentId, path = "") {
        return urlFrom(`${tournamentApiBase}/${tournamentId}${path}`);
    }

    function badge(status, map) {
        return map[status] || ["gray", status || "-"];
    }

    function teamName(teamId) {
        return teams.find((team) => Number(team.iddoibong) === Number(teamId))?.tendoibong || `#${teamId}`;
    }

    function venueName(venueId) {
        return venues.find((venue) => Number(venue.idsandau) === Number(venueId))?.tensandau || `#${venueId}`;
    }

    function formatDisplayDateTime(value) {
        if (!value) {
            return "";
        }

        const normalized = String(value).replace("T", " ");
        return normalized.length >= 16 ? normalized.slice(0, 16) : normalized;
    }

    function toInputDateTime(value) {
        if (!value) {
            return "";
        }

        return String(value).replace(" ", "T").slice(0, 16);
    }

    function toApiDateTime(value) {
        if (!value) {
            return null;
        }

        const normalized = String(value).replace("T", " ");
        return normalized.length === 16 ? `${normalized}:00` : normalized;
    }

    function selectedValues(selectElement) {
        return Array.from(selectElement.selectedOptions)
            .map((option) => Number(option.value))
            .filter((value) => Number.isInteger(value) && value > 0);
    }

    function sameNumberArray(left, right) {
        const a = [...left].map(Number).sort((x, y) => x - y);
        const b = [...right].map(Number).sort((x, y) => x - y);

        return a.length === b.length && a.every((value, index) => value === b[index]);
    }

    function fillSelect(selectElement, items, valueKey, labelKey, placeholder = null, selectedValue = "") {
        let html = "";

        if (placeholder !== null) {
            html += `<option value="">${escapeHtml(placeholder)}</option>`;
        }

        html += items.map((item) => {
            const value = item[valueKey];
            const label = typeof labelKey === "function" ? labelKey(item) : item[labelKey];
            const selected = String(value) === String(selectedValue) ? " selected" : "";
            return `<option value="${escapeHtml(value)}"${selected}>${escapeHtml(label)}</option>`;
        }).join("");

        selectElement.innerHTML = html;
    }

    function fillTeamMultiSelect(selectedTeamIds = []) {
        const selected = selectedTeamIds.map(Number);
        gmTeams.innerHTML = teams.map((team) => {
            const id = Number(team.iddoibong);
            const isSelected = selected.includes(id) ? " selected" : "";
            return `<option value="${escapeHtml(id)}"${isSelected}>${escapeHtml(team.tendoibong)}</option>`;
        }).join("");
    }

    function refreshGroupSelects() {
        const activeGroups = groups.filter((group) => group.trangthai !== "DA_XOA");

        fillSelect(
            mGroup,
            activeGroups,
            "idbangdau",
            "tenbang",
            "Tất cả, gồm trận ngoài bảng",
            mGroup.value
        );
        fillSelect(mmGroup, activeGroups, "idbangdau", "tenbang", "Không thuộc bảng", mmGroup.value);
    }

    function refreshMatchSelects() {
        fillSelect(mmTeam1, teams, "iddoibong", "tendoibong", null, mmTeam1.value);
        fillSelect(mmTeam2, teams, "iddoibong", "tendoibong", null, mmTeam2.value);
        fillSelect(mmVenue, venues, "idsandau", "tensandau", null, mmVenue.value);
    }

    function setSelectedTournamentFromList(id) {
        const found = tournaments.find((item) => Number(item.idgiaidau) === Number(id));

        if (found) {
            selectedTournament = found;
        }
    }

    async function loadTournaments() {
        showMessage("Đang tải danh sách giải đấu...");

        try {
            const payload = await requestJson(urlFrom(scheduleTournamentsApi, { q: tQ.value.trim() }));
            tournaments = Array.isArray(payload.data) ? payload.data : [];
            renderTournaments();
            showMessage("");
        } catch (error) {
            tournaments = [];
            tList.innerHTML = '<li class="empty">Không thể tải danh sách giải đấu.</li>';
            showMessage(error.message || "Không thể tải danh sách giải đấu.", true);
        }
    }

    function renderTournaments() {
        if (tournaments.length === 0) {
            tList.innerHTML = '<li class="empty">Không có giải đấu đã công bố và đã đóng đăng ký.</li>';
            return;
        }

        tList.innerHTML = tournaments.map((tournament) => {
            const active = selectedTournament && Number(tournament.idgiaidau) === Number(selectedTournament.idgiaidau);
            return `
                <li class="item${active ? " active" : ""}" data-action="select-tournament" data-id="${escapeHtml(tournament.idgiaidau)}">
                    <div class="title">${escapeHtml(tournament.tengiaidau)}</div>
                    <div class="meta">${escapeHtml(tournament.diadiem || "")}</div>
                    <div class="meta">${escapeHtml(tournament.total_teams || 0)} đội - ${escapeHtml(tournament.total_groups || 0)} bảng - ${escapeHtml(tournament.total_matches || 0)} trận</div>
                </li>
            `;
        }).join("");
    }

    async function selectTournament(id) {
        setSelectedTournamentFromList(id);
        btnAddGroup.disabled = true;
        btnAddMatch.disabled = true;
        showMessage("Đang tải lịch thi đấu...");

        try {
            const payload = await requestJson(tournamentUrl(id, "/schedule"));
            const data = payload.data || {};

            selectedTournament = data.tournament || selectedTournament;
            teams = Array.isArray(data.teams) ? data.teams : [];
            venues = Array.isArray(data.venues) ? data.venues : [];
            groups = Array.isArray(data.groups) ? data.groups : [];
            matches = Array.isArray(data.matches) ? data.matches : [];

            tourName.textContent = selectedTournament?.tengiaidau || "Chưa chọn giải đấu";
            tourSub.textContent = [
                selectedTournament?.diadiem || "",
                `Trạng thái: ${selectedTournament?.trangthai || ""}`,
                `Đăng ký: ${selectedTournament?.trangthaidangky || ""}`,
                `${teams.length} đội`,
            ].filter(Boolean).join(" - ");

            btnAddGroup.disabled = false;
            btnAddMatch.disabled = teams.length < 2 || venues.length === 0;
            refreshGroupSelects();
            refreshMatchSelects();
            renderTournaments();
            renderGroups();
            renderMatches();
            showMessage("");
        } catch (error) {
            showMessage(error.message || "Không thể tải lịch thi đấu.", true);
            gTbody.innerHTML = '<tr><td colspan="6" class="empty">Không thể tải bảng đấu.</td></tr>';
            mTbody.innerHTML = '<tr><td colspan="9" class="empty">Không thể tải trận đấu.</td></tr>';
        }
    }

    function groupRows() {
        const keyword = gQ.value.trim().toLowerCase();

        return groups.filter((group) => {
            const haystack = `${group.tenbang || ""} ${group.mota || ""}`.toLowerCase();
            return !keyword || haystack.includes(keyword);
        });
    }

    function renderGroups() {
        const data = groupRows();

        if (!selectedTournament) {
            gTbody.innerHTML = '<tr><td colspan="6" class="empty">Chưa chọn giải đấu.</td></tr>';
            return;
        }

        if (data.length === 0) {
            gTbody.innerHTML = '<tr><td colspan="6" class="empty">Chưa có bảng đấu phù hợp.</td></tr>';
            return;
        }

        gTbody.innerHTML = data.map((group) => {
            const [className, label] = badge(group.trangthai, GROUP_STATUSES);
            const teamCount = Array.isArray(group.teams) ? group.teams.length : Number(group.total_teams || 0);

            return `
                <tr>
                    <td>${escapeHtml(group.idbangdau)}</td>
                    <td>${escapeHtml(group.tenbang)}</td>
                    <td>${escapeHtml(group.mota || "")}</td>
                    <td>${escapeHtml(teamCount)}</td>
                    <td><span class="badge ${className}">${escapeHtml(label)}</span></td>
                    <td>
                        <button class="btn" type="button" data-action="edit-group" data-id="${escapeHtml(group.idbangdau)}">Sửa</button>
                    </td>
                </tr>
            `;
        }).join("");
    }

    function filteredMatches() {
        const groupId = mGroup.value ? Number(mGroup.value) : null;

        if (!groupId) {
            return matches;
        }

        return matches.filter((match) => Number(match.idbangdau) === groupId);
    }

    function renderMatches() {
        const data = filteredMatches();

        if (!selectedTournament) {
            mTbody.innerHTML = '<tr><td colspan="9" class="empty">Chưa chọn giải đấu.</td></tr>';
            return;
        }

        if (data.length === 0) {
            mTbody.innerHTML = '<tr><td colspan="9" class="empty">Chưa có trận đấu phù hợp.</td></tr>';
            return;
        }

        mTbody.innerHTML = data.map((match) => {
            const [className, label] = badge(match.trangthai, MATCH_STATUSES);

            return `
                <tr>
                    <td>${escapeHtml(match.idtrandau)}</td>
                    <td>${escapeHtml(match.doi1 || teamName(match.iddoibong1))}</td>
                    <td>${escapeHtml(match.doi2 || teamName(match.iddoibong2))}</td>
                    <td>${escapeHtml(match.tensandau || venueName(match.idsandau))}</td>
                    <td>${escapeHtml(formatDisplayDateTime(match.thoigianbatdau))}</td>
                    <td>${escapeHtml(formatDisplayDateTime(match.thoigianketthuc))}</td>
                    <td>${escapeHtml(match.vongdau || "")}</td>
                    <td><span class="badge ${className}">${escapeHtml(label)}</span></td>
                    <td>
                        <button class="btn" type="button" data-action="edit-match" data-id="${escapeHtml(match.idtrandau)}">Sửa</button>
                    </td>
                </tr>
            `;
        }).join("");
    }

    function currentGroup() {
        return groups.find((group) => Number(group.idbangdau) === Number(editingGroupId)) || null;
    }

    function currentMatch() {
        return matches.find((match) => Number(match.idtrandau) === Number(editingMatchId)) || null;
    }

    function openCreateGroup() {
        if (!selectedTournament) {
            return;
        }

        editingGroupId = null;
        hideModalError(gmAlert);
        gmTitle.textContent = "Thêm bảng đấu";
        gmName.value = "";
        gmStatus.value = "HOAT_DONG";
        gmDesc.value = "";
        fillTeamMultiSelect([]);
        gmDelete.disabled = true;
        groupModal.classList.remove("hidden");
    }

    function openEditGroup(groupId) {
        const group = groups.find((item) => Number(item.idbangdau) === Number(groupId));

        if (!group) {
            return;
        }

        editingGroupId = Number(groupId);
        hideModalError(gmAlert);
        gmTitle.textContent = "Sửa bảng đấu";
        gmName.value = group.tenbang || "";
        gmStatus.value = group.trangthai || "HOAT_DONG";
        gmDesc.value = group.mota || "";
        fillTeamMultiSelect((group.teams || []).map((team) => Number(team.iddoibong)));
        gmDelete.disabled = Number(group.total_matches || 0) > 0 || group.trangthai === "DA_XOA";
        groupModal.classList.remove("hidden");
    }

    function closeGroupModal() {
        groupModal.classList.add("hidden");
        editingGroupId = null;
    }

    function groupPayload() {
        return {
            tenbang: gmName.value.trim(),
            trangthai: gmStatus.value,
            mota: gmDesc.value.trim() || null,
            team_ids: selectedValues(gmTeams),
        };
    }

    function validateGroup(payload) {
        if (!payload.tenbang) {
            return "Vui lòng nhập tên bảng đấu.";
        }

        return null;
    }

    function changedGroupPayload(payload) {
        const group = currentGroup();

        if (!group) {
            return payload;
        }

        const changes = {};

        if (payload.tenbang !== String(group.tenbang || "")) {
            changes.tenbang = payload.tenbang;
        }

        if (payload.trangthai !== String(group.trangthai || "")) {
            changes.trangthai = payload.trangthai;
        }

        if ((payload.mota || null) !== (group.mota || null)) {
            changes.mota = payload.mota;
        }

        const currentTeamIds = (group.teams || []).map((team) => Number(team.iddoibong));

        if (!sameNumberArray(payload.team_ids, currentTeamIds)) {
            changes.team_ids = payload.team_ids;
        }

        return changes;
    }

    async function saveGroup() {
        hideModalError(gmAlert);
        const payload = groupPayload();
        const validationError = validateGroup(payload);

        if (validationError) {
            showModalError(gmAlert, validationError);
            return;
        }

        gmSave.disabled = true;

        try {
            if (editingGroupId) {
                const changes = changedGroupPayload(payload);

                if (Object.keys(changes).length === 0) {
                    showModalError(gmAlert, "Không có dữ liệu thay đổi.");
                    return;
                }

                await requestJson(tournamentUrl(selectedTournament.idgiaidau, `/groups/${editingGroupId}`), {
                    method: "PATCH",
                    body: JSON.stringify(changes),
                });
                closeGroupModal();
                await selectTournament(selectedTournament.idgiaidau);
                showMessage("Cập nhật bảng đấu thành công.");
                return;
            }

            await requestJson(tournamentUrl(selectedTournament.idgiaidau, "/groups"), {
                method: "POST",
                body: JSON.stringify(payload),
            });
            closeGroupModal();
            await selectTournament(selectedTournament.idgiaidau);
            showMessage("Thêm bảng đấu thành công.");
        } catch (error) {
            showModalError(gmAlert, error.message || "Không thể lưu bảng đấu.");
        } finally {
            gmSave.disabled = false;
        }
    }

    async function deleteGroup() {
        if (!editingGroupId || !window.confirm("Xóa bảng đấu? Hệ thống sẽ chuyển trạng thái bảng sang DA_XOA.")) {
            return;
        }

        gmDelete.disabled = true;

        try {
            await requestJson(tournamentUrl(selectedTournament.idgiaidau, `/groups/${editingGroupId}/delete`), {
                method: "POST",
                body: JSON.stringify({ lydo: "Xoa bang dau tu giao dien quan ly lich thi dau" }),
            });
            closeGroupModal();
            await selectTournament(selectedTournament.idgiaidau);
            showMessage("Xóa bảng đấu thành công.");
        } catch (error) {
            showModalError(gmAlert, error.message || "Không thể xóa bảng đấu.");
            gmDelete.disabled = false;
        }
    }

    function openCreateMatch() {
        if (!selectedTournament) {
            return;
        }

        editingMatchId = null;
        hideModalError(mmAlert);
        mmTitle.textContent = "Thêm trận đấu";
        refreshGroupSelects();
        refreshMatchSelects();
        mmGroup.value = mGroup.value || "";
        mmRound.value = "Vòng bảng";
        mmStatus.value = "CHUA_DIEN_RA";
        mmStart.value = "";
        mmEnd.value = "";

        if (teams.length > 0) {
            mmTeam1.value = String(teams[0].iddoibong);
        }

        if (teams.length > 1) {
            mmTeam2.value = String(teams[1].iddoibong);
        }

        if (venues.length > 0) {
            mmVenue.value = String(venues[0].idsandau);
        }

        mmDelete.disabled = true;
        matchModal.classList.remove("hidden");
    }

    function openEditMatch(matchId) {
        const match = matches.find((item) => Number(item.idtrandau) === Number(matchId));

        if (!match) {
            return;
        }

        editingMatchId = Number(matchId);
        hideModalError(mmAlert);
        mmTitle.textContent = "Sửa trận đấu";
        refreshGroupSelects();
        refreshMatchSelects();
        mmGroup.value = match.idbangdau || "";
        mmRound.value = match.vongdau || "";
        mmTeam1.value = String(match.iddoibong1);
        mmTeam2.value = String(match.iddoibong2);
        mmVenue.value = String(match.idsandau);
        mmStatus.value = match.trangthai || "CHUA_DIEN_RA";
        mmStart.value = toInputDateTime(match.thoigianbatdau);
        mmEnd.value = toInputDateTime(match.thoigianketthuc);
        mmDelete.disabled = !["CHUA_DIEN_RA", "SAP_DIEN_RA"].includes(String(match.trangthai));
        matchModal.classList.remove("hidden");
    }

    function closeMatchModal() {
        matchModal.classList.add("hidden");
        editingMatchId = null;
    }

    function matchPayload() {
        return {
            idbangdau: mmGroup.value ? Number(mmGroup.value) : null,
            vongdau: mmRound.value.trim(),
            iddoibong1: mmTeam1.value ? Number(mmTeam1.value) : null,
            iddoibong2: mmTeam2.value ? Number(mmTeam2.value) : null,
            idsandau: mmVenue.value ? Number(mmVenue.value) : null,
            trangthai: mmStatus.value,
            thoigianbatdau: toApiDateTime(mmStart.value),
            thoigianketthuc: toApiDateTime(mmEnd.value),
        };
    }

    function validateMatch(payload) {
        if (!payload.vongdau) {
            return "Vui lòng nhập vòng đấu.";
        }

        if (!payload.iddoibong1 || !payload.iddoibong2) {
            return "Vui lòng chọn đủ 2 đội.";
        }

        if (payload.iddoibong1 === payload.iddoibong2) {
            return "Đội 1 phải khác đội 2.";
        }

        if (!payload.idsandau) {
            return "Vui lòng chọn sân đấu.";
        }

        if (!payload.thoigianbatdau) {
            return "Vui lòng chọn thời gian bắt đầu.";
        }

        if (payload.thoigianketthuc && new Date(payload.thoigianketthuc) <= new Date(payload.thoigianbatdau)) {
            return "Thời gian kết thúc phải lớn hơn thời gian bắt đầu.";
        }

        return null;
    }

    function changedMatchPayload(payload) {
        const match = currentMatch();

        if (!match) {
            return payload;
        }

        const changes = {};
        const current = {
            idbangdau: match.idbangdau === null ? null : Number(match.idbangdau),
            vongdau: String(match.vongdau || ""),
            iddoibong1: Number(match.iddoibong1),
            iddoibong2: Number(match.iddoibong2),
            idsandau: Number(match.idsandau),
            trangthai: String(match.trangthai || ""),
            thoigianbatdau: toApiDateTime(toInputDateTime(match.thoigianbatdau)),
            thoigianketthuc: toApiDateTime(toInputDateTime(match.thoigianketthuc)),
        };

        Object.entries(payload).forEach(([key, value]) => {
            if (value !== current[key]) {
                changes[key] = value;
            }
        });

        return changes;
    }

    async function saveMatch() {
        hideModalError(mmAlert);
        const payload = matchPayload();
        const validationError = validateMatch(payload);

        if (validationError) {
            showModalError(mmAlert, validationError);
            return;
        }

        mmSave.disabled = true;

        try {
            if (editingMatchId) {
                const changes = changedMatchPayload(payload);

                if (Object.keys(changes).length === 0) {
                    showModalError(mmAlert, "Không có dữ liệu thay đổi.");
                    return;
                }

                await requestJson(tournamentUrl(selectedTournament.idgiaidau, `/matches/${editingMatchId}`), {
                    method: "PATCH",
                    body: JSON.stringify(changes),
                });
                closeMatchModal();
                await selectTournament(selectedTournament.idgiaidau);
                showMessage("Cập nhật trận đấu thành công.");
                return;
            }

            await requestJson(tournamentUrl(selectedTournament.idgiaidau, "/matches"), {
                method: "POST",
                body: JSON.stringify(payload),
            });
            closeMatchModal();
            await selectTournament(selectedTournament.idgiaidau);
            showMessage("Thêm trận đấu thành công.");
        } catch (error) {
            showModalError(mmAlert, error.message || "Không thể lưu trận đấu.");
        } finally {
            mmSave.disabled = false;
        }
    }

    async function deleteMatch() {
        if (!editingMatchId || !window.confirm("Xóa trận đấu? Hệ thống sẽ chuyển trạng thái trận sang DA_HUY.")) {
            return;
        }

        mmDelete.disabled = true;

        try {
            await requestJson(tournamentUrl(selectedTournament.idgiaidau, `/matches/${editingMatchId}/delete`), {
                method: "POST",
                body: JSON.stringify({ lydo: "Xoa tran dau tu giao dien quan ly lich thi dau" }),
            });
            closeMatchModal();
            await selectTournament(selectedTournament.idgiaidau);
            showMessage("Xóa trận đấu thành công.");
        } catch (error) {
            showModalError(mmAlert, error.message || "Không thể xóa trận đấu.");
            mmDelete.disabled = false;
        }
    }

    tRefresh.addEventListener("click", loadTournaments);
    tQ.addEventListener("input", loadTournaments);
    gQ.addEventListener("input", renderGroups);
    mGroup.addEventListener("change", renderMatches);
    btnAddGroup.addEventListener("click", openCreateGroup);
    btnAddMatch.addEventListener("click", openCreateMatch);

    gmClose.addEventListener("click", closeGroupModal);
    gmCancel.addEventListener("click", closeGroupModal);
    gmSave.addEventListener("click", saveGroup);
    gmDelete.addEventListener("click", deleteGroup);

    mmClose.addEventListener("click", closeMatchModal);
    mmCancel.addEventListener("click", closeMatchModal);
    mmSave.addEventListener("click", saveMatch);
    mmDelete.addEventListener("click", deleteMatch);

    tList.addEventListener("click", (event) => {
        const item = event.target.closest("[data-action='select-tournament']");

        if (item) {
            selectTournament(item.dataset.id);
        }
    });

    gTbody.addEventListener("click", (event) => {
        const button = event.target.closest("[data-action='edit-group']");

        if (button) {
            openEditGroup(button.dataset.id);
        }
    });

    mTbody.addEventListener("click", (event) => {
        const button = event.target.closest("[data-action='edit-match']");

        if (button) {
            openEditMatch(button.dataset.id);
        }
    });

    loadTournaments();
})();
