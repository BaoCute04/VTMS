const root = document.querySelector(".organizer-tournaments");
const tournamentsApi = root?.dataset.tournamentsApi || "/api/organizer/tournaments";
const optionsApi = root?.dataset.optionsApi || "/api/organizer/tournament-options";
const eligibilityPreviewApi = root?.dataset.eligibilityPreviewApi || "/api/organizer/tournament-eligibility-preview";

let tournaments = [];
let tournamentOptions = { levels: [], regions: [], rules: [], achievement_levels: [] };
let editingId = null;
let editingTournament = null;
let currentTournamentId = null;
let rejectingRegistrationId = null;
let eligibilityPreview = null;

const tbody = document.getElementById("tbody");
const q = document.getElementById("q");
const statusFilter = document.getElementById("statusFilter");
const regFilter = document.getElementById("regFilter");
const fromDate = document.getElementById("fromDate");
const toDate = document.getElementById("toDate");
const btnRefresh = document.getElementById("btnRefresh");
const btnCreate = document.getElementById("btnCreate");
const pageMessage = document.getElementById("pageMessage");

const tournamentModal = document.getElementById("tournamentModal");
const regModal = document.getElementById("regModal");
const rejectModal = document.getElementById("rejectModal");

const fields = {
    title: document.getElementById("modalTitle"),
    name: document.getElementById("m_name"),
    level: document.getElementById("m_level"),
    levelHint: document.getElementById("m_level_hint"),
    region: document.getElementById("m_scope_region"),
    law: document.getElementById("m_law"),
    nature: document.getElementById("m_nature"),
    start: document.getElementById("m_start"),
    end: document.getElementById("m_end"),
    size: document.getElementById("m_size"),
    image: document.getElementById("m_image"),
    imageFile: document.getElementById("m_image_file"),
    imageHint: document.getElementById("m_image_hint"),
    placeNote: document.getElementById("m_place_note"),
    desc: document.getElementById("m_desc"),
    minTeams: document.getElementById("m_min_teams"),
    maxTeams: document.getElementById("m_max_teams"),
    teamCountHint: document.getElementById("m_team_count_hint"),
    minPlayers: document.getElementById("m_min_players"),
    maxPlayers: document.getElementById("m_max_players"),
    fee: document.getElementById("m_fee"),
    achievementLevel: document.getElementById("m_achievement_level"),
    achievementRequirements: Array.from(document.querySelectorAll('input[name="m_achievement_requirement"]')),
    recentSeasons: document.getElementById("m_recent_seasons"),
    officialOnly: document.getElementById("m_official_only"),
    allowException: document.getElementById("m_allow_exception"),
    eligibilityHint: document.getElementById("m_eligibility_hint"),
    ruleTitle: document.getElementById("m_rule_title"),
    ruleContent: document.getElementById("m_rule_content"),
    formatType: document.getElementById("m_format_type"),
    pairing: document.getElementById("m_pairing"),
    teamSelection: document.getElementById("m_team_selection"),
    alert: document.getElementById("m_alert"),
    regTitle: document.getElementById("r_tourName"),
    regStatus: document.getElementById("r_status"),
    regSearch: document.getElementById("r_q"),
    regTable: document.getElementById("r_tbody"),
    rejectInfo: document.getElementById("rej_info"),
    rejectReason: document.getElementById("rej_reason"),
    rejectAlert: document.getElementById("rej_alert"),
};

const buttons = {
    modalClose: document.getElementById("m_close"),
    modalCancel: document.getElementById("m_cancel"),
    modalSave: document.getElementById("m_save"),
    regClose: document.getElementById("r_close"),
    regCloseBottom: document.getElementById("r_closeBtn"),
    rejectClose: document.getElementById("rej_close"),
    rejectCancel: document.getElementById("rej_cancel"),
    rejectConfirm: document.getElementById("rej_confirm"),
};

const tournamentStatusLabels = {
    NHAP: "Nháp",
    CHUA_CONG_BO: "Chưa công bố",
    DA_CONG_BO: "Đã công bố",
    DANG_DIEN_RA: "Đang diễn ra",
    DA_KET_THUC: "Đã kết thúc",
    DA_HUY: "Đã hủy",
};

const registrationWindowLabels = {
    CHUA_MO: "Chưa mở",
    DANG_MO: "Đang mở",
    DA_DONG: "Đã đóng",
};

const registrationStatusLabels = {
    CHO_DUYET: "Chờ duyệt",
    DA_DUYET: "Đã duyệt",
    TU_CHOI: "Từ chối",
    DA_HUY: "Đã hủy",
};

const natureLabels = {
    CHINH_THUC: "Chính thức",
    GIAO_HUU: "Giao hữu",
    PHONG_TRAO: "Phong trào",
    NOI_BO: "Nội bộ",
    MO_RONG: "Mở rộng",
};

const achievementBasedRequirements = new Set(["VO_DICH", "A_QUAN", "HANG_BA", "TOP_N", "THEO_XEP_HANG"]);

function escapeHtml(value) {
    return String(value ?? "")
        .replaceAll("&", "&amp;")
        .replaceAll("<", "&lt;")
        .replaceAll(">", "&gt;")
        .replaceAll('"', "&quot;")
        .replaceAll("'", "&#039;");
}

function setPageMessage(message, success = false) {
    pageMessage.textContent = message || "";
    pageMessage.classList.toggle("success", success);
}

function showAlert(element, message) {
    element.textContent = message;
    element.classList.remove("hidden");
}

function hideAlert(element) {
    element.textContent = "";
    element.classList.add("hidden");
}

async function apiRequest(url, options = {}) {
    const isFormData = options.body instanceof FormData;
    const response = await fetch(url, {
        credentials: "same-origin",
        headers: {
            Accept: "application/json",
            ...(isFormData ? {} : { "Content-Type": "application/json" }),
            ...(options.headers || {}),
        },
        ...options,
    });
    const payload = await response.json().catch(() => ({}));

    if (!response.ok || payload.success === false) {
        const details = payload.errors ? Object.values(payload.errors).join(" ") : "";
        throw new Error([payload.message, details].filter(Boolean).join(" ") || "Yêu cầu không thành công.");
    }

    return payload;
}

function tournamentId(item) {
    return Number(item.idgiaidau || item.id);
}

function registrationId(item) {
    return Number(item.iddangky || item.id);
}

function statusClass(status) {
    if (status === "DA_CONG_BO") return "pub";
    if (status === "DANG_DIEN_RA") return "run";
    if (status === "DA_KET_THUC") return "end";
    if (status === "DA_HUY") return "cancel";
    return "draft";
}

function regWindowClass(status) {
    if (status === "DANG_MO") return "reg-on";
    if (status === "DA_DONG") return "reg-closed";
    return "reg-off";
}

function todayIsoDate() {
    const today = new Date();
    const year = today.getFullYear();
    const month = String(today.getMonth() + 1).padStart(2, "0");
    const day = String(today.getDate()).padStart(2, "0");
    return `${year}-${month}-${day}`;
}

function isBeforeTournamentStart(item) {
    const startDate = String(item?.thoigianbatdau || "").slice(0, 10);
    return /^\d{4}-\d{2}-\d{2}$/.test(startDate) && startDate > todayIsoDate();
}

function canEditTournament(item) {
    return isBeforeTournamentStart(item) && !["DANG_DIEN_RA", "DA_KET_THUC", "DA_HUY"].includes(String(item?.trangthai || ""));
}

function registrationClass(status) {
    if (status === "DA_DUYET") return "approved";
    if (status === "TU_CHOI" || status === "DA_HUY") return "rejected";
    return "pending";
}

function selectedImageMode() {
    return document.querySelector('input[name="m_image_mode"]:checked')?.value || "url";
}

function setImageMode(mode) {
    const normalized = mode === "upload" ? "upload" : "url";
    const radio = document.querySelector(`input[name="m_image_mode"][value="${normalized}"]`);
    if (radio) radio.checked = true;
    updateImageMode();
}

function updateImageMode() {
    const upload = selectedImageMode() === "upload";
    fields.image.classList.toggle("hidden", upload);
    fields.imageFile.classList.toggle("hidden", !upload);
    fields.imageHint.textContent = upload
        ? "Chọn ảnh JPG, PNG hoặc WEBP tối đa 5MB. Hệ thống sẽ lưu ảnh và gắn đường dẫn vào giải đấu."
        : "Nhập URL ảnh đã lưu trữ công khai.";
}

function levelById(id) {
    return tournamentOptions.levels.find((item) => Number(item.idcapgiaidau) === Number(id)) || null;
}

function regionsForLevel(levelId) {
    return tournamentOptions.regions.filter((item) => Number(item.idcapgiaidau) === Number(levelId));
}

function selectedRegion() {
    return tournamentOptions.regions.find((item) => Number(item.idkhuvuc) === Number(fields.region.value)) || null;
}

function achievementLevelsForSelectedTournamentLevel() {
    const level = levelById(fields.level.value);
    if (!level) return [];
    return (tournamentOptions.achievement_levels || []).filter((item) => String(item.macapgiaidau) === String(level.capdoituongthamgia));
}

function selectedParticipantTeamType() {
    return String(levelById(fields.level.value)?.capdoituongthamgia || "");
}

function selectedAchievementRequirements() {
    return fields.achievementRequirements.filter((item) => item.checked).map((item) => item.value);
}

function setAchievementRequirements(values = []) {
    const selected = new Set(values);
    for (const input of fields.achievementRequirements) {
        input.checked = selected.has(input.value);
    }
}

function achievementSelectionsFromConditions(conditions = []) {
    const explicit = conditions
        .filter((condition) => ["VO_DICH", "A_QUAN", "HANG_BA"].includes(condition.yeu_cau_thanh_tich))
        .map((condition) => condition.yeu_cau_thanh_tich);
    if (explicit.length > 0) return explicit;

    const topCondition = conditions.find((condition) => ["TOP_N", "THEO_XEP_HANG"].includes(condition.yeu_cau_thanh_tich));
    const maxRank = Number(topCondition?.hang_toi_thieu_duoc_phep || 0);
    return ["VO_DICH", "A_QUAN", "HANG_BA"].slice(0, Math.min(3, Math.max(0, maxRank)));
}

function storedAchievementSelections(item, conditions = []) {
    if (Array.isArray(item?.thanh_tich_duoc_phep) && item.thanh_tich_duoc_phep.length > 0) {
        return item.thanh_tich_duoc_phep;
    }

    return achievementSelectionsFromConditions(conditions);
}

function formatTypeFromStoredFormat(format) {
    const hasPointRound = Number(format?.co_vong_diem || 0) === 1;
    const hasKnockoutRound = Number(format?.co_vong_loai || 0) === 1;
    if (hasPointRound && hasKnockoutRound) return "KET_HOP";
    if (hasKnockoutRound) return "VONG_LOAI";
    return "VONG_DIEM";
}

function fillNumberSelect(select, min, max, selectedValue = "") {
    const normalizedMin = Number(min);
    const normalizedMax = Number(max);
    if (!Number.isFinite(normalizedMin) || !Number.isFinite(normalizedMax) || normalizedMax < normalizedMin) {
        select.innerHTML = '<option value="">Không có lựa chọn phù hợp</option>';
        select.value = "";
        return;
    }

    const selected = String(selectedValue || normalizedMin);
    select.innerHTML = Array.from({ length: normalizedMax - normalizedMin + 1 }, (_, index) => normalizedMin + index)
        .map((value) => `<option value="${value}">${value}</option>`)
        .join("");
    select.value = select.querySelector(`option[value="${selected}"]`) ? selected : String(normalizedMin);
}

function updateTeamLimitOptions(preferred = {}, preview = eligibilityPreview) {
    const region = selectedRegion();
    const activeTeams = Number(region?.active_team_count || 0);
    const eligibleTeams = Number(preview?.eligible_team_count ?? activeTeams);
    const selectedMax = Number(preferred.maxTeams || fields.maxTeams.value || fields.size.value || 0);
    const maxSelectable = Math.max(64, selectedMax, activeTeams, eligibleTeams, 2);

    fillNumberSelect(fields.minTeams, 2, Math.max(2, maxSelectable - 1), preferred.minTeams || fields.minTeams.value || 2);
    fillNumberSelect(fields.maxTeams, 2, maxSelectable, preferred.maxTeams || fields.maxTeams.value || Math.max(2, selectedMax || eligibleTeams || activeTeams || 2));

    fields.minTeams.disabled = false;
    fields.maxTeams.disabled = false;

    if (preview) {
        fields.teamCountHint.textContent = `Có ${eligibleTeams} đội đủ điều kiện theo cấp giải nguồn, thành tích và mùa giải đang chọn. Số đội tối đa có thể đặt lớn hơn để nhận thêm đăng ký hoặc ngoại lệ.`;
    } else {
        fields.teamCountHint.textContent = `Khu vực này hiện có ${activeTeams} đội đang hoạt động phù hợp cấp giải. Chọn điều kiện thành tích để tính số đội hợp lệ.`;
    }

    const maxTeams = Number(fields.maxTeams.value || 0);
    if (maxTeams > 0) {
        fields.size.max = String(maxTeams);
        fields.size.value = String(maxTeams);
    }
}

function syncTeamLimitsFromScale() {
    const scale = Number(fields.size.value || 0);
    if (!scale) return;
    if (fields.maxTeams.querySelector(`option[value="${scale}"]`)) {
        fields.maxTeams.value = String(scale);
    }
    const minTeams = Number(fields.minTeams.value || 0);
    if (minTeams >= scale && fields.minTeams.querySelector(`option[value="${Math.max(2, scale - 1)}"]`)) {
        fields.minTeams.value = String(Math.max(2, scale - 1));
    }
}

function syncScaleFromMaxTeams() {
    const maxTeams = Number(fields.maxTeams.value || 0);
    if (maxTeams > 0) {
        fields.size.value = String(maxTeams);
        fields.size.max = String(maxTeams);
    }
}

function fillOptionSelects() {
    fields.level.innerHTML = '<option value="">Chọn cấp giải...</option>' + tournamentOptions.levels.map((item) => (
        `<option value="${Number(item.idcapgiaidau)}">${escapeHtml(item.tencapgiaidau || item.macapgiaidau)}</option>`
    )).join("");

    fields.law.innerHTML = '<option value="">Chọn luật thi đấu...</option>' + tournamentOptions.rules.map((item) => {
        const label = `${item.tenluat}${item.kieu_tran ? ` (${item.kieu_tran})` : ""}`;
        return `<option value="${Number(item.idluat)}">${escapeHtml(label)}</option>`;
    }).join("");

    updateRegionsForSelectedLevel();
    updateEligibilityControls();
}

function updateRegionsForSelectedLevel(selectedRegionId = "") {
    const levelId = Number(fields.level.value || 0);
    const regions = regionsForLevel(levelId);
    fields.region.innerHTML = regions.length === 0
        ? '<option value="">Không có khu vực phù hợp</option>'
        : regions.map((item) => `<option value="${Number(item.idkhuvuc)}">${escapeHtml(item.tenkhuvuc)} (${escapeHtml(item.capkhuvuc)})</option>`).join("");

    if (selectedRegionId) {
        fields.region.value = String(selectedRegionId);
    }

    const level = levelById(levelId);
    fields.levelHint.textContent = level
        ? `Cấp đội tham gia được suy ra: ${level.capdoituongthamgia}. Phạm vi: ${level.capkhuvucphamvi}.`
        : "BTC chỉ được tạo giải đúng cấp và khu vực quản lý.";
    eligibilityPreview = null;
    updateTeamLimitOptions();
    updateEligibilityControls();
    refreshEligibilityPreview();
}

function updateEligibilityControls(selectedAchievementLevelId = "") {
    const level = levelById(fields.level.value);
    const participantLevel = String(level?.capdoituongthamgia || "");
    const achievementLevels = achievementLevelsForSelectedTournamentLevel();
    const achievementRequired = selectedAchievementRequirements().some((item) => achievementBasedRequirements.has(item));

    fields.achievementLevel.innerHTML = achievementLevels.length === 0
        ? '<option value="">Không có cấp giải nguồn phù hợp</option>'
        : achievementLevels.map((item) => (
            `<option value="${Number(item.idcapgiaidau)}">${escapeHtml(item.tencapgiaidau || item.macapgiaidau)}</option>`
        )).join("");

    if (selectedAchievementLevelId && fields.achievementLevel.querySelector(`option[value="${selectedAchievementLevelId}"]`)) {
        fields.achievementLevel.value = String(selectedAchievementLevelId);
    }

    fields.achievementLevel.disabled = !achievementRequired || achievementLevels.length === 0;
    if (!achievementRequired) {
        fields.achievementLevel.value = "";
    }

    fields.eligibilityHint.textContent = participantLevel
        ? `Đội tham gia được suy ra là cấp ${participantLevel}. Khi yêu cầu thành tích, cấp giải nguồn phải cùng cấp này.`
        : "Chọn cấp giải hiện tại để hệ thống xác định cấp đội tham gia.";
}

function buildEligibilityPreviewUrl() {
    const requirements = selectedAchievementRequirements();
    const params = new URLSearchParams({
        idcapgiaidau: fields.level.value,
        idkhuvucphamvi: fields.region.value,
        capdoituongthamgia: selectedParticipantTeamType(),
        thanh_tich_duoc_phep: requirements.length > 0 ? requirements.join(",") : "KHONG_YEU_CAU",
        idcapgiaidau_thanh_tich_nguon: fields.achievementLevel.value,
        so_mua_giai_gan_nhat_duoc_tinh: fields.recentSeasons.value || "1",
        chi_tinh_giai_chinh_thuc: fields.officialOnly.checked ? "1" : "0",
        bat_buoc_cung_khuvuc: "1",
        cho_phep_btc_duyet_ngoai_le: fields.allowException.checked ? "1" : "0",
    });

    return `${eligibilityPreviewApi}?${params.toString()}`;
}

async function refreshEligibilityPreview(preferred = {}) {
    const level = levelById(fields.level.value);
    const requirements = selectedAchievementRequirements();
    const achievementBased = requirements.some((item) => achievementBasedRequirements.has(item));

    if (!level || !fields.region.value || (achievementBased && !fields.achievementLevel.value)) {
        eligibilityPreview = null;
        updateTeamLimitOptions(preferred);
        return;
    }

    fields.teamCountHint.textContent = "Đang tính số đội đủ điều kiện...";

    try {
        const payload = await apiRequest(buildEligibilityPreviewUrl());
        eligibilityPreview = payload.data || null;
        updateTeamLimitOptions(preferred, eligibilityPreview);
    } catch (error) {
        eligibilityPreview = null;
        updateTeamLimitOptions(preferred);
        fields.teamCountHint.textContent = error.message;
    }
}

async function loadOptions() {
    const payload = await apiRequest(optionsApi);
    tournamentOptions = payload.data || tournamentOptions;
    fillOptionSelects();
}

function buildTournamentUrl() {
    const params = new URLSearchParams();
    if (q.value.trim() !== "") params.set("q", q.value.trim());
    if (statusFilter.value !== "") params.set("status", statusFilter.value);
    if (regFilter.value !== "") params.set("registration_status", regFilter.value);
    if (fromDate.value !== "") params.set("from", fromDate.value);
    if (toDate.value !== "") params.set("to", toDate.value);
    const query = params.toString();
    return query === "" ? tournamentsApi : `${tournamentsApi}?${query}`;
}

async function loadTournaments() {
    tbody.innerHTML = '<tr><td colspan="8" class="empty">Đang tải dữ liệu...</td></tr>';
    setPageMessage("");

    try {
        const payload = await apiRequest(buildTournamentUrl());
        tournaments = payload.data || [];
        renderTournaments();
    } catch (error) {
        tournaments = [];
        renderTournaments();
        setPageMessage(error.message);
    }
}

function renderTournaments() {
    if (tournaments.length === 0) {
        tbody.innerHTML = '<tr><td colspan="8" class="empty">Không có giải đấu phù hợp.</td></tr>';
        return;
    }

    tbody.innerHTML = tournaments.map((item) => {
        const id = tournamentId(item);
        const status = item.trangthai || "";
        const regStatus = item.trangthaidangky || "";
        const approved = Number(item.dangky_da_duyet || 0);
        const pending = Number(item.dangky_cho_duyet || 0);
        const levelRegion = [
            item.tencapgiaidau || item.macapgiaidau,
            item.tenkhuvuc_phamvi || item.ghichu_diadiem,
        ].filter(Boolean).join(" - ");

        return `
            <tr>
                <td>${id}</td>
                <td>
                    <strong>${escapeHtml(item.tengiaidau)}</strong>
                    <span class="truncate" title="${escapeHtml(item.mota || "")}">${escapeHtml(item.mota || "")}</span>
                </td>
                <td>${escapeHtml(item.thoigianbatdau)} - ${escapeHtml(item.thoigianketthuc)}</td>
                <td>
                    <strong>${escapeHtml(levelRegion)}</strong>
                    <span class="sub">${escapeHtml(natureLabels[item.tinhchat] || item.tinhchat || "")}</span>
                </td>
                <td>${Number(item.quymo || 0)}<br><span class="sub">Duyệt: ${approved}, chờ: ${pending}</span></td>
                <td><span class="badge ${statusClass(status)}">${escapeHtml(tournamentStatusLabels[status] || status)}</span></td>
                <td><span class="badge ${regWindowClass(regStatus)}">${escapeHtml(registrationWindowLabels[regStatus] || regStatus)}</span></td>
                <td>${rowActions(item)}</td>
            </tr>
        `;
    }).join("");
}

function rowActions(item) {
    const id = tournamentId(item);
    const status = item.trangthai || "";
    const regStatus = item.trangthaidangky || "";
    const canEditDraft = status === "NHAP" || status === "CHUA_CONG_BO";
    const canEdit = canEditTournament(item);
    const canPublish = canEditDraft;
    const canOpenReg = status === "DA_CONG_BO" && (regStatus === "CHUA_MO" || regStatus === "DA_DONG");
    const canCloseReg = status === "DA_CONG_BO" && regStatus === "DANG_MO";

    return `
        <div class="row-actions">
            <button class="btn" type="button" data-action="registrations" data-id="${id}">Đăng ký</button>
            ${canPublish ? `<button class="btn primary" type="button" data-action="publish" data-id="${id}">Công bố & mở ĐK</button>` : ""}
            ${canOpenReg ? `<button class="btn" type="button" data-action="open-reg" data-id="${id}">Mở ĐK</button>` : ""}
            ${canCloseReg ? `<button class="btn" type="button" data-action="close-reg" data-id="${id}">Đóng ĐK</button>` : ""}
            ${canEdit ? `<button class="btn" type="button" data-action="edit" data-id="${id}">Sửa</button>` : ""}
            ${canEditDraft ? `<button class="btn danger" type="button" data-action="delete" data-id="${id}">Xóa</button>` : ""}
        </div>
    `;
}

function findTournament(id) {
    return tournaments.find((item) => tournamentId(item) === Number(id)) || null;
}

async function fetchTournament(id) {
    const payload = await apiRequest(`${tournamentsApi}/${id}`);
    return payload.data;
}

function openTournamentModal(mode, item = null) {
    hideAlert(fields.alert);
    editingId = null;
    editingTournament = item;

    fields.title.textContent = "Tạo giải đấu";
    buttons.modalSave.textContent = "Lưu";
    fields.name.value = "";
    fields.level.value = tournamentOptions.levels[0]?.idcapgiaidau ? String(tournamentOptions.levels[0].idcapgiaidau) : "";
    updateRegionsForSelectedLevel();
    fields.law.value = tournamentOptions.rules[0]?.idluat ? String(tournamentOptions.rules[0].idluat) : "";
    fields.nature.value = "CHINH_THUC";
    fields.start.value = "";
    fields.end.value = "";
    fields.size.value = "10";
    updateTeamLimitOptions({ minTeams: 2, maxTeams: 10 });
    fillNumberSelect(fields.minPlayers, 6, 14, 6);
    fillNumberSelect(fields.maxPlayers, 6, 14, 14);
    fields.fee.value = "0";
    setAchievementRequirements([]);
    fields.recentSeasons.value = "1";
    fields.officialOnly.checked = true;
    fields.allowException.checked = false;
    updateEligibilityControls();
    refreshEligibilityPreview({ minTeams: 2, maxTeams: 10 });
    fields.image.value = "";
    fields.imageFile.value = "";
    fields.placeNote.value = "";
    fields.desc.value = "";
    fields.ruleTitle.value = "Điều lệ giải đấu";
    fields.ruleContent.value = "";
    fields.formatType.value = "KET_HOP";
    fields.pairing.value = "HYBRID";
    fields.teamSelection.value = "KET_HOP";
    setImageMode("url");

    if (mode === "edit" && item) {
        editingId = tournamentId(item);
        fields.title.textContent = "Sửa giải đấu";
        buttons.modalSave.textContent = "Cập nhật";
        fields.name.value = item.tengiaidau || "";
        fields.level.value = item.idcapgiaidau ? String(item.idcapgiaidau) : "";
        updateRegionsForSelectedLevel(item.idkhuvucphamvi || "");
        fields.law.value = item.idluat ? String(item.idluat) : "";
        fields.nature.value = item.tinhchat || "CHINH_THUC";
        fields.start.value = item.thoigianbatdau || "";
        fields.end.value = item.thoigianketthuc || "";
        fields.size.value = item.quymo || 10;
        fields.image.value = item.hinhanh || "";
        fields.placeNote.value = item.ghichu_diadiem || "";
        fields.desc.value = item.mota || "";

        if (item.dieule) {
            fields.minTeams.value = item.dieule.so_doi_toi_thieu || 2;
            fields.maxTeams.value = item.dieule.so_doi_toi_da || item.quymo || 10;
            fields.minPlayers.value = item.dieule.so_vdv_toi_thieu_moi_doi || 6;
            fields.maxPlayers.value = item.dieule.so_vdv_toi_da_moi_doi || 14;
            fields.fee.value = item.dieule.le_phi_tham_gia ?? "0";
            fields.ruleTitle.value = item.dieule.tieude || "Điều lệ giải đấu";
            fields.ruleContent.value = item.dieule.noidung_chinh ?? item.dieule.noidung ?? "";
        }

        updateTeamLimitOptions({
            minTeams: fields.minTeams.value,
            maxTeams: fields.maxTeams.value,
        });
        fillNumberSelect(fields.minPlayers, 6, 14, fields.minPlayers.value || 6);
        fillNumberSelect(fields.maxPlayers, 6, 14, fields.maxPlayers.value || 14);

        if (item.thethuc) {
            fields.formatType.value = formatTypeFromStoredFormat(item.thethuc);
            fields.pairing.value = item.thethuc.cach_xep_mac_dinh || "HYBRID";
        }

        if (item.quytac) {
            fields.teamSelection.value = item.quytac.chedochondoi || "KET_HOP";
        }

        const conditions = Array.isArray(item.dieukien) ? item.dieukien : (item.dieukien ? [item.dieukien] : []);
        const achievementConditions = conditions.filter((condition) => ["VO_DICH", "A_QUAN", "HANG_BA"].includes(condition.yeu_cau_thanh_tich));
        const firstCondition = achievementConditions[0] || conditions[0] || item.quytac || {};
        setAchievementRequirements(storedAchievementSelections(item, conditions));
        fields.recentSeasons.value = String(firstCondition.so_mua_giai_gan_nhat_duoc_tinh || 1);
        fields.officialOnly.checked = Number(firstCondition.chi_tinh_giai_chinh_thuc ?? 1) === 1;
        fields.allowException.checked = Number(firstCondition.cho_phep_btc_duyet_ngoai_le ?? 0) === 1;
        updateEligibilityControls(firstCondition.idcapgiaidau_thanh_tich_nguon || "");
        refreshEligibilityPreview({
            minTeams: fields.minTeams.value,
            maxTeams: fields.maxTeams.value,
        });
    }

    tournamentModal.classList.remove("hidden");
    tournamentModal.setAttribute("aria-hidden", "false");
    fields.name.focus();
}

function closeTournamentModal() {
    tournamentModal.classList.add("hidden");
    tournamentModal.setAttribute("aria-hidden", "true");
    editingId = null;
    editingTournament = null;
    hideAlert(fields.alert);
}

function collectTournamentPayload() {
    const imageMode = selectedImageMode();
    const scale = Number(fields.maxTeams.value || fields.size.value || 0);
    const selectedLevel = levelById(fields.level.value);
    const achievementRequirements = selectedAchievementRequirements();
    const achievementBased = achievementRequirements.some((item) => achievementBasedRequirements.has(item));
    const achievementLevelId = achievementBased && fields.achievementLevel.value ? Number(fields.achievementLevel.value) : null;
    const eligibility = {
        capdoituongthamgia: selectedLevel?.capdoituongthamgia || "DON_VI",
        thanh_tich_duoc_phep: achievementRequirements.length > 0 ? achievementRequirements : ["KHONG_YEU_CAU"],
        idcapgiaidau_thanh_tich_nguon: achievementLevelId,
        hang_toi_thieu_duoc_phep: null,
        so_mua_giai_gan_nhat_duoc_tinh: Number(fields.recentSeasons.value || 1),
        cho_phep_btc_duyet_ngoai_le: fields.allowException.checked,
    };

    return {
        tengiaidau: fields.name.value.trim(),
        idcapgiaidau: fields.level.value ? Number(fields.level.value) : null,
        idkhuvucphamvi: fields.region.value ? Number(fields.region.value) : null,
        idluat: fields.law.value ? Number(fields.law.value) : null,
        tinhchat: fields.nature.value,
        thoigianbatdau: fields.start.value,
        thoigianketthuc: fields.end.value,
        quymo: scale,
        hinhanh: imageMode === "url" ? (fields.image.value.trim() || null) : (editingTournament?.hinhanh || null),
        image_mode: imageMode,
        image_upload_name: imageMode === "upload" && fields.imageFile.files[0] ? fields.imageFile.files[0].name : null,
        ghichu_diadiem: fields.placeNote.value.trim() || null,
        mota: fields.desc.value.trim() || null,
        dieule: {
            tieude: fields.ruleTitle.value.trim() || "Điều lệ giải đấu",
            noidung: fields.ruleContent.value.trim() || null,
            so_doi_toi_thieu: Number(fields.minTeams.value || 2),
            so_doi_toi_da: Number(fields.maxTeams.value || scale),
            so_vdv_toi_thieu_moi_doi: Number(fields.minPlayers.value || 6),
            so_vdv_toi_da_moi_doi: Number(fields.maxPlayers.value || 14),
            le_phi_tham_gia: fields.fee.value === "" ? 0 : Number(fields.fee.value),
            cho_phep_dang_ky_tu_do: fields.teamSelection.value !== "BTC_CHON_THU_CONG",
            yeu_cau_duyet_dang_ky: true,
        },
        thethuc: {
            loai_the_thuc: fields.formatType.value,
            co_tranh_hang_ba: fields.formatType.value !== "VONG_DIEM",
            cach_xep_mac_dinh: fields.pairing.value,
            seed_source_mac_dinh: "BTC_NHAP_TAY",
        },
        quytac: {
            chedochondoi: fields.teamSelection.value,
            soluongdoitoida: scale,
            ...eligibility,
        },
        dieukien: {
            ten_dieukien: "Điều kiện tham gia mặc định",
            chi_tinh_giai_chinh_thuc: fields.officialOnly.checked,
            bat_buoc_cung_khuvuc: true,
            ...eligibility,
        },
    };
}

function validateTournamentPayload(payload) {
    if (payload.tengiaidau === "") return "Vui lòng nhập tên giải đấu.";
    if (!payload.idcapgiaidau) return "Vui lòng chọn cấp giải đấu.";
    if (!payload.idkhuvucphamvi) return "Vui lòng chọn khu vực phạm vi.";
    if (!payload.idluat) return "Vui lòng chọn luật thi đấu.";
    if (payload.thoigianbatdau === "" || payload.thoigianketthuc === "") return "Vui lòng nhập ngày bắt đầu và ngày kết thúc.";
    if (payload.thoigianketthuc < payload.thoigianbatdau) return "Ngày kết thúc phải lớn hơn hoặc bằng ngày bắt đầu.";
    if (!Number.isInteger(payload.quymo) || payload.quymo <= 0) return "Quy mô phải là số nguyên lớn hơn 0.";
    if (payload.dieule.so_doi_toi_thieu < 2) return "Số đội tối thiểu phải từ 2 trở lên.";
    if (payload.dieule.so_doi_toi_da <= payload.dieule.so_doi_toi_thieu) return "Số đội tối đa phải lớn hơn số đội tối thiểu.";
    if (payload.dieule.so_doi_toi_da < payload.quymo) return "Số đội tối đa trong điều lệ phải lớn hơn hoặc bằng quy mô giải.";
    if (payload.dieule.so_vdv_toi_thieu_moi_doi < 6 || payload.dieule.so_vdv_toi_thieu_moi_doi > 14) return "Số VĐV tối thiểu mỗi đội phải từ 6 đến 14.";
    if (payload.dieule.so_vdv_toi_da_moi_doi < 6 || payload.dieule.so_vdv_toi_da_moi_doi > 14) return "Số VĐV tối đa mỗi đội phải từ 6 đến 14.";
    if (payload.dieule.so_vdv_toi_da_moi_doi < payload.dieule.so_vdv_toi_thieu_moi_doi) return "Số VĐV tối đa mỗi đội phải lớn hơn hoặc bằng số tối thiểu.";
    if (Number.isNaN(payload.dieule.le_phi_tham_gia) || payload.dieule.le_phi_tham_gia < 0) return "Lệ phí tham gia phải là số không âm.";
    if (payload.dieukien.thanh_tich_duoc_phep.some((item) => achievementBasedRequirements.has(item)) && !payload.dieukien.idcapgiaidau_thanh_tich_nguon) return "Vui lòng chọn cấp giải nguồn của thành tích.";
    if (payload.image_mode === "upload" && !payload.image_upload_name && !payload.hinhanh) return "Vui lòng chọn tệp ảnh hoặc chuyển sang chế độ gắn URL.";
    return "";
}

function requestBodyFromTournamentPayload(payload) {
    const shouldUploadImage = payload.image_mode === "upload" && fields.imageFile.files[0];
    if (!shouldUploadImage) return JSON.stringify(payload);

    const formData = new FormData();
    for (const [key, value] of Object.entries(payload)) {
        if (["dieule", "thethuc", "quytac", "dieukien"].includes(key)) {
            formData.append(key, JSON.stringify(value));
            continue;
        }
        if (value !== null && value !== undefined) formData.append(key, String(value));
    }
    formData.append("hinhanh_file", fields.imageFile.files[0]);
    return formData;
}

async function saveTournament() {
    const payload = collectTournamentPayload();
    const validation = validateTournamentPayload(payload);
    hideAlert(fields.alert);

    if (validation !== "") {
        showAlert(fields.alert, validation);
        return;
    }

    buttons.modalSave.disabled = true;
    try {
        const body = requestBodyFromTournamentPayload(payload);
        if (editingId) {
            const isFormData = body instanceof FormData;
            await apiRequest(isFormData ? `${tournamentsApi}/${editingId}/update` : `${tournamentsApi}/${editingId}`, {
                method: isFormData ? "POST" : "PATCH",
                body,
            });
            setPageMessage("Cập nhật giải đấu thành công.", true);
        } else {
            await apiRequest(tournamentsApi, { method: "POST", body });
            setPageMessage("Tạo giải đấu thành công.", true);
        }
        closeTournamentModal();
        await loadTournaments();
    } catch (error) {
        showAlert(fields.alert, error.message);
    } finally {
        buttons.modalSave.disabled = false;
    }
}

async function publishTournament(id) {
    if (!window.confirm("Công bố giải đấu và mở đăng ký? Sau khi công bố sẽ hạn chế sửa.")) return;
    setPageMessage("");

    try {
        await apiRequest(`${tournamentsApi}/${id}/publish`, { method: "POST", body: JSON.stringify({}) });
        await apiRequest(`${tournamentsApi}/${id}/registrations/open`, { method: "POST", body: JSON.stringify({}) });
        setPageMessage("Công bố giải đấu và mở đăng ký thành công.", true);
        await loadTournaments();
    } catch (error) {
        setPageMessage(error.message);
        await loadTournaments();
    }
}

async function runTournamentAction(url, successMessage, options = {}) {
    setPageMessage("");
    try {
        await apiRequest(url, { method: "POST", body: JSON.stringify({}), ...options });
        setPageMessage(successMessage, true);
        await loadTournaments();
    } catch (error) {
        setPageMessage(error.message);
    }
}

async function openRegistrations(id) {
    const item = findTournament(id);
    currentTournamentId = Number(id);
    fields.regTitle.textContent = item
        ? `${item.tengiaidau} - Trạng thái ĐK: ${registrationWindowLabels[item.trangthaidangky] || item.trangthaidangky}`
        : `Giải đấu #${id}`;
    fields.regStatus.value = "";
    fields.regSearch.value = "";
    regModal.classList.remove("hidden");
    regModal.setAttribute("aria-hidden", "false");
    await loadRegistrations();
}

function closeRegistrations() {
    regModal.classList.add("hidden");
    regModal.setAttribute("aria-hidden", "true");
    currentTournamentId = null;
    fields.regTable.innerHTML = "";
}

function buildRegistrationUrl() {
    const params = new URLSearchParams();
    if (fields.regStatus.value !== "") params.set("status", fields.regStatus.value);
    if (fields.regSearch.value.trim() !== "") params.set("q", fields.regSearch.value.trim());
    const query = params.toString();
    const base = `${tournamentsApi}/${currentTournamentId}/registrations`;
    return query === "" ? base : `${base}?${query}`;
}

async function loadRegistrations() {
    if (!currentTournamentId) return;
    fields.regTable.innerHTML = '<tr><td colspan="7" class="empty">Đang tải dữ liệu...</td></tr>';

    try {
        const payload = await apiRequest(buildRegistrationUrl());
        renderRegistrations(payload.data || []);
    } catch (error) {
        fields.regTable.innerHTML = `<tr><td colspan="7" class="empty">${escapeHtml(error.message)}</td></tr>`;
    }
}

function renderRegistrations(registrations) {
    if (registrations.length === 0) {
        fields.regTable.innerHTML = '<tr><td colspan="7" class="empty">Không có đăng ký phù hợp.</td></tr>';
        return;
    }

    fields.regTable.innerHTML = registrations.map((item) => {
        const id = registrationId(item);
        const status = item.trangthai || "";
        const actionable = status === "CHO_DUYET";
        return `
            <tr>
                <td>${id}</td>
                <td><strong>${escapeHtml(item.tendoibong)}</strong><span class="sub">${escapeHtml(item.doibong_diaphuong || "")}</span></td>
                <td>${escapeHtml(item.huanluyenvien_hoten || item.huanluyenvien_username || "")}<span class="sub">${escapeHtml(item.huanluyenvien_email || "")}</span></td>
                <td>${escapeHtml(item.ngaydangky)}</td>
                <td><span class="badge ${registrationClass(status)}">${escapeHtml(registrationStatusLabels[status] || status)}</span></td>
                <td><span class="truncate" title="${escapeHtml(item.lydotuchoi || "")}">${escapeHtml(item.lydotuchoi || "")}</span></td>
                <td>
                    <div class="row-actions">
                        <button class="btn primary" type="button" data-action="approve-reg" data-id="${id}" ${actionable ? "" : "disabled"}>Duyệt</button>
                        <button class="btn danger" type="button" data-action="reject-reg" data-id="${id}" data-team="${escapeHtml(item.tendoibong)}" ${actionable ? "" : "disabled"}>Từ chối</button>
                    </div>
                </td>
            </tr>
        `;
    }).join("");
}

async function approveRegistration(id) {
    try {
        await apiRequest(`${tournamentsApi}/${currentTournamentId}/registrations/${id}/approve`, { method: "POST", body: JSON.stringify({}) });
        setPageMessage("Duyệt đăng ký thành công.", true);
        await loadRegistrations();
        await loadTournaments();
    } catch (error) {
        setPageMessage(error.message);
    }
}

function openRejectRegistration(id, teamName) {
    rejectingRegistrationId = Number(id);
    fields.rejectInfo.textContent = `ĐK #${id} - Đội: ${teamName || ""}`;
    fields.rejectReason.value = "";
    hideAlert(fields.rejectAlert);
    rejectModal.classList.remove("hidden");
    rejectModal.setAttribute("aria-hidden", "false");
    fields.rejectReason.focus();
}

function closeRejectRegistration() {
    rejectModal.classList.add("hidden");
    rejectModal.setAttribute("aria-hidden", "true");
    rejectingRegistrationId = null;
    hideAlert(fields.rejectAlert);
}

async function rejectRegistration() {
    const reason = fields.rejectReason.value.trim();
    if (reason === "") {
        showAlert(fields.rejectAlert, "Vui lòng nhập lý do từ chối.");
        return;
    }

    buttons.rejectConfirm.disabled = true;
    try {
        await apiRequest(`${tournamentsApi}/${currentTournamentId}/registrations/${rejectingRegistrationId}/reject`, {
            method: "POST",
            body: JSON.stringify({ lydotuchoi: reason }),
        });
        closeRejectRegistration();
        setPageMessage("Từ chối đăng ký thành công.", true);
        await loadRegistrations();
        await loadTournaments();
    } catch (error) {
        showAlert(fields.rejectAlert, error.message);
    } finally {
        buttons.rejectConfirm.disabled = false;
    }
}

tbody.addEventListener("click", async (event) => {
    const button = event.target.closest("button[data-action]");
    if (!button) return;

    const id = Number(button.dataset.id);
    const action = button.dataset.action;

    if (action === "registrations") return openRegistrations(id);
    if (action === "publish") return publishTournament(id);
    if (action === "open-reg") return runTournamentAction(`${tournamentsApi}/${id}/registrations/open`, "Mở đăng ký giải đấu thành công.");
    if (action === "close-reg") return runTournamentAction(`${tournamentsApi}/${id}/registrations/close`, "Đóng đăng ký giải đấu thành công.");
    if (action === "delete") {
        if (window.confirm("Xóa giải đấu nháp/chưa công bố này?")) {
            return runTournamentAction(`${tournamentsApi}/${id}`, "Xóa giải đấu thành công.", { method: "DELETE" });
        }
        return;
    }
    if (action === "edit") {
        try {
            openTournamentModal("edit", await fetchTournament(id));
        } catch (error) {
            setPageMessage(error.message);
        }
    }
});

fields.regTable.addEventListener("click", async (event) => {
    const button = event.target.closest("button[data-action]");
    if (!button || button.disabled) return;

    const id = Number(button.dataset.id);
    if (button.dataset.action === "approve-reg") return approveRegistration(id);
    if (button.dataset.action === "reject-reg") openRejectRegistration(id, button.dataset.team || "");
});

btnCreate.addEventListener("click", () => openTournamentModal("create"));
buttons.modalClose.addEventListener("click", closeTournamentModal);
buttons.modalCancel.addEventListener("click", closeTournamentModal);
buttons.modalSave.addEventListener("click", saveTournament);
buttons.regClose.addEventListener("click", closeRegistrations);
buttons.regCloseBottom.addEventListener("click", closeRegistrations);
buttons.rejectClose.addEventListener("click", closeRejectRegistration);
buttons.rejectCancel.addEventListener("click", closeRejectRegistration);
buttons.rejectConfirm.addEventListener("click", rejectRegistration);
btnRefresh.addEventListener("click", loadTournaments);
statusFilter.addEventListener("change", loadTournaments);
regFilter.addEventListener("change", loadTournaments);
fromDate.addEventListener("change", loadTournaments);
toDate.addEventListener("change", loadTournaments);
fields.level.addEventListener("change", () => updateRegionsForSelectedLevel());
fields.region.addEventListener("change", () => refreshEligibilityPreview());
fields.achievementLevel.addEventListener("change", () => refreshEligibilityPreview());
for (const checkbox of fields.achievementRequirements) {
    checkbox.addEventListener("change", () => {
        updateEligibilityControls();
        refreshEligibilityPreview();
    });
}
fields.recentSeasons.addEventListener("change", () => refreshEligibilityPreview());
fields.officialOnly.addEventListener("change", () => refreshEligibilityPreview());
fields.allowException.addEventListener("change", () => refreshEligibilityPreview());
fields.size.addEventListener("input", syncTeamLimitsFromScale);
fields.maxTeams.addEventListener("change", syncScaleFromMaxTeams);
fields.minTeams.addEventListener("change", () => {
    const minTeams = Number(fields.minTeams.value || 0);
    const maxTeams = Number(fields.maxTeams.value || 0);
    if (minTeams >= maxTeams && fields.maxTeams.options.length > 0) {
        const next = Array.from(fields.maxTeams.options).find((option) => Number(option.value) > minTeams);
        if (next) fields.maxTeams.value = next.value;
        syncScaleFromMaxTeams();
    }
});

for (const radio of document.querySelectorAll('input[name="m_image_mode"]')) {
    radio.addEventListener("change", updateImageMode);
}

fields.regStatus.addEventListener("change", loadRegistrations);
fields.regSearch.addEventListener("input", () => {
    clearTimeout(window.__registrationSearchTimer);
    window.__registrationSearchTimer = setTimeout(loadRegistrations, 250);
});

for (const modal of [tournamentModal, regModal, rejectModal]) {
    modal.addEventListener("click", (event) => {
        if (event.target !== modal) return;
        if (modal === tournamentModal) closeTournamentModal();
        else if (modal === regModal) closeRegistrations();
        else closeRejectRegistration();
    });
}

document.addEventListener("keydown", (event) => {
    if (event.key !== "Escape") return;
    if (!rejectModal.classList.contains("hidden")) return closeRejectRegistration();
    if (!regModal.classList.contains("hidden")) return closeRegistrations();
    if (!tournamentModal.classList.contains("hidden")) closeTournamentModal();
});

(async function init() {
    updateImageMode();
    try {
        await loadOptions();
    } catch (error) {
        setPageMessage(error.message);
    }
    await loadTournaments();
})();
