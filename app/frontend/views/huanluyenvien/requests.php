<section class="coach-page coach-requests" data-requests-api="<?= e(url('/api/coach/athlete-change-requests')) ?>">
    <header class="coach-topbar">
        <div>
            <p class="eyebrow">HUAN LUYEN VIEN</p>
            <h1>Yêu cầu xác nhận thay đổi thông tin</h1>
            <p class="sub">Các yêu cầu thay đổi thông tin từ vận động viên thuộc đội bóng của HLV.</p>
        </div>
    </header>

    <section class="coach-toolbar">
        <input id="q" placeholder="Tìm theo VĐV / bảng / trường / giá trị" />
        <select id="statusFilter">
            <option value="">Tất cả trạng thái</option>
            <option value="CHO_DUYET">Chờ duyệt</option>
            <option value="DA_DUYET">Đã duyệt</option>
            <option value="TU_CHOI">Từ chối</option>
        </select>
        <input type="date" id="fromDate" />
        <input type="date" id="toDate" />
        <button id="btnRefresh" class="btn" type="button">Làm mới</button>
    </section>

    <section id="empty" class="coach-card empty hidden">Hiện tại không có yêu cầu.</section>

    <div id="pageMessage" class="coach-message"></div>

    <div class="table-wrap">
        <table class="coach-table" id="requestTable">
            <thead>
                <tr>
                    <th>Mã YC</th>
                    <th>Vận động viên</th>
                    <th>Bảng</th>
                    <th>Trường</th>
                    <th>Giá trị cũ</th>
                    <th>Giá trị mới</th>
                    <th>Ngày gửi</th>
                    <th>Trạng thái</th>
                    <th></th>
                </tr>
            </thead>
            <tbody id="tbody"><tr><td colspan="9" class="empty">Đang tải dữ liệu...</td></tr></tbody>
        </table>
    </div>
</section>

<div class="coach-modal hidden" id="detailModal" aria-hidden="true">
    <div class="modal-content wide" role="dialog" aria-modal="true">
        <div class="modal-head">
            <h2>Chi tiết thay đổi thông tin</h2>
            <button class="icon" id="m_close" type="button" aria-label="Đóng">×</button>
        </div>

        <div class="compare">
            <div>
                <h4>Thông tin hiện tại</h4>
                <pre id="oldInfo"></pre>
            </div>
            <div>
                <h4>Thông tin đề xuất</h4>
                <pre id="newInfo"></pre>
            </div>
        </div>

        <label for="m_note">Ghi chú khi từ chối</label>
        <textarea id="m_note" rows="3"></textarea>
        <div id="m_alert" class="coach-alert hidden"></div>

        <div class="coach-actions">
            <button class="btn" id="btnReject" type="button">Từ chối</button>
            <button class="btn primary" id="btnApprove" type="button">Duyệt</button>
        </div>
    </div>
</div>
