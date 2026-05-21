const root = document.querySelector(".organizer-teams");
const eligibilityApi = root?.dataset.eligibilityApi || "/api/organizer/higher-eligibility";

let candidates = [];
let incoming = [];
let searchTimer = null;

const q = document.getElementById("q");
const btnRefresh = document.getElementById("btnRefresh");
const candidateBody = document.getElementById("candidateBody");
const incomingBody = document.getElementById("incomingBody");
const pageMessage = document.getElementById("pageMessage");

const statusLabels = {
    DU_DIEU_KIEN: "Đủ điều kiện",
    DA_DE_CU: "Đã đề cử",
    DA_XAC_NHAN: "Đã xác nhận",
    TU_CHOI: "Từ chối",
};

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

function statusClass(status) {
    if (status === "DU_DIEU_KIEN" || status === "DA_XAC_NHAN") return "ok";
    if (status === "DA_DE_CU") return "wait";
    if (status === "TU_CHOI") return "lock";
    return "gray";
}

async function apiRequest(url, options = {}) {
    const response = await fetch(url, {
        credentials: "same-origin",
        headers: {
            Accept: "application/json",
            "Content-Type": "application/json",
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

function buildUrl() {
    const params = new URLSearchParams();
    if (q.value.trim() !== "") params.set("q", q.value.trim());
    const query = params.toString();
    return query === "" ? eligibilityApi : `${eligibilityApi}?${query}`;
}

async function loadData() {
    candidateBody.innerHTML = '<tr><td colspan="6" class="empty">Đang tải dữ liệu...</td></tr>';
    incomingBody.innerHTML = '<tr><td colspan="6" class="empty">Đang tải dữ liệu...</td></tr>';
    setPageMessage("");

    try {
        const payload = await apiRequest(buildUrl());
        candidates = payload.data?.candidates || [];
        incoming = payload.data?.incoming || [];
        renderCandidates();
        renderIncoming();
    } catch (error) {
        candidates = [];
        incoming = [];
        renderCandidates();
        renderIncoming();
        setPageMessage(error.message);
    }
}

function renderCandidates() {
    if (candidates.length === 0) {
        candidateBody.innerHTML = '<tr><td colspan="6" class="empty">Chưa có đội vô địch phù hợp để đề cử.</td></tr>';
        return;
    }

    candidateBody.innerHTML = candidates.map((item) => {
        const status = item.trangthai_decu || "CHUA_DANH_DAU";
        const statusText = statusLabels[status] || "Chưa đánh dấu";
        const canMark = status === "CHUA_DANH_DAU" || status === "TU_CHOI";
        const canNominate = status === "DU_DIEU_KIEN" && Number(item.iddecu || 0) > 0;

        return `
            <tr>
                <td>
                    <strong>${escapeHtml(item.tendoibong)}</strong>
                    <span class="sub">${escapeHtml(item.tenkhuvuc_doi || item.diaphuong || "")}</span>
                </td>
                <td>
                    <strong>${escapeHtml(item.tengiaidau_nguon)}</strong>
                    <span class="sub">${escapeHtml(item.tencapgiaidau_nguon)} - Vô địch ${escapeHtml(item.ngay_cong_nhan || "")}</span>
                </td>
                <td>
                    <strong>${escapeHtml(item.tengiaidau_dich)}</strong>
                    <span class="sub">${escapeHtml(item.tencapgiaidau_dich)} - ${escapeHtml(item.tenkhuvuc_dich || "")}</span>
                </td>
                <td>${escapeHtml(item.bantochuc_nhan || "")}</td>
                <td><span class="badge ${statusClass(status)}">${escapeHtml(statusText)}</span></td>
                <td>
                    <div class="row-actions">
                        ${canMark ? `<button class="btn" type="button" data-action="mark" data-achievement-id="${Number(item.idthanhtich)}" data-target-id="${Number(item.idgiaidau_dich)}">Đủ điều kiện</button>` : ""}
                        ${canNominate ? `<button class="btn primary" type="button" data-action="nominate" data-id="${Number(item.iddecu)}">Đề cử</button>` : ""}
                    </div>
                </td>
            </tr>
        `;
    }).join("");
}

function renderIncoming() {
    if (incoming.length === 0) {
        incomingBody.innerHTML = '<tr><td colspan="6" class="empty">Chưa có đề cử gửi đến.</td></tr>';
        return;
    }

    incomingBody.innerHTML = incoming.map((item) => {
        const status = item.trangthai || "";
        const actionable = status === "DA_DE_CU";

        return `
            <tr>
                <td>
                    <strong>${escapeHtml(item.tendoibong)}</strong>
                    <span class="sub">${escapeHtml(item.tenkhuvuc_doi || item.diaphuong || "")}</span>
                </td>
                <td>${escapeHtml(item.bantochuc_decu || "")}</td>
                <td>
                    <strong>${escapeHtml(item.tengiaidau_nguon)}</strong>
                    <span class="sub">${escapeHtml(item.tencapgiaidau_nguon)} - Vô địch ${escapeHtml(item.ngay_cong_nhan || "")}</span>
                </td>
                <td>
                    <strong>${escapeHtml(item.tengiaidau_dich)}</strong>
                    <span class="sub">${escapeHtml(item.tencapgiaidau_dich)}</span>
                </td>
                <td><span class="badge ${statusClass(status)}">${escapeHtml(statusLabels[status] || status)}</span></td>
                <td>
                    <div class="row-actions">
                        <button class="btn primary" type="button" data-action="approve" data-id="${Number(item.iddecu)}" ${actionable ? "" : "disabled"}>Xác nhận</button>
                        <button class="btn" type="button" data-action="reject" data-id="${Number(item.iddecu)}" ${actionable ? "" : "disabled"}>Từ chối</button>
                    </div>
                </td>
            </tr>
        `;
    }).join("");
}

async function markEligible(achievementId, targetTournamentId) {
    const note = window.prompt("Ghi chú xét đủ điều kiện", "Đội vô địch đạt điều kiện đề cử cấp cao hơn.") || "";

    await apiRequest(`${eligibilityApi}/mark`, {
        method: "POST",
        body: JSON.stringify({
            idthanhtich: achievementId,
            idgiaidau_dich: targetTournamentId,
            ghichu: note,
        }),
    });
    setPageMessage("Đã đánh dấu đủ điều kiện.", true);
    await loadData();
}

async function nominate(proposalId) {
    const note = window.prompt("Ghi chú gửi BTC cấp cao hơn", "Đề cử đội đủ điều kiện tham gia giải cấp cao hơn.") || "";

    await apiRequest(`${eligibilityApi}/${proposalId}/nominate`, {
        method: "POST",
        body: JSON.stringify({ ghichu: note }),
    });
    setPageMessage("Đã gửi đề cử.", true);
    await loadData();
}

async function approve(proposalId) {
    const note = window.prompt("Ghi chú xác nhận đề cử", "Đội hợp lệ, xác nhận suất tham gia cấp cao hơn.") || "";

    await apiRequest(`${eligibilityApi}/${proposalId}/approve`, {
        method: "POST",
        body: JSON.stringify({ ghichu: note }),
    });
    setPageMessage("Đã xác nhận đề cử.", true);
    await loadData();
}

async function reject(proposalId) {
    const reason = window.prompt("Lý do từ chối đề cử");
    if (reason === null || reason.trim() === "") return;

    await apiRequest(`${eligibilityApi}/${proposalId}/reject`, {
        method: "POST",
        body: JSON.stringify({ lydo: reason.trim() }),
    });
    setPageMessage("Đã từ chối đề cử.", true);
    await loadData();
}

async function handleAction(button) {
    try {
        const action = button.dataset.action;
        if (action === "mark") {
            await markEligible(Number(button.dataset.achievementId), Number(button.dataset.targetId));
        } else if (action === "nominate") {
            await nominate(Number(button.dataset.id));
        } else if (action === "approve") {
            await approve(Number(button.dataset.id));
        } else if (action === "reject") {
            await reject(Number(button.dataset.id));
        }
    } catch (error) {
        setPageMessage(error.message);
    }
}

candidateBody.addEventListener("click", (event) => {
    const button = event.target.closest("button[data-action]");
    if (button) handleAction(button);
});

incomingBody.addEventListener("click", (event) => {
    const button = event.target.closest("button[data-action]");
    if (button) handleAction(button);
});

btnRefresh.addEventListener("click", loadData);
q.addEventListener("input", () => {
    clearTimeout(searchTimer);
    searchTimer = setTimeout(loadData, 250);
});

loadData();
