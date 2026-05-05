<section
    class="organizer-tournaments"
    data-tournaments-api="<?= e(url('/api/organizer/tournaments')) ?>"
>
    <header class="tournaments-topbar">
        <div>
            <p class="eyebrow">BAN TO CHUC</p>
            <h1>Quản lý giải đấu</h1>
            <p class="sub">Tạo, cập nhật giải chưa công bố, công bố, mở/đóng đăng ký và duyệt đội tham gia.</p>
        </div>
        <button id="btnCreate" class="btn primary" type="button">Tạo giải đấu</button>
    </header>

    <section class="tournaments-toolbar" aria-label="Bộ lọc giải đấu">
        <input id="q" type="text" placeholder="Tìm theo tên giải / địa điểm" />

        <select id="statusFilter">
            <option value="">Tất cả trạng thái</option>
            <option value="CHUA_CONG_BO">Chưa công bố</option>
            <option value="DA_CONG_BO">Đã công bố</option>
            <option value="DANG_DIEN_RA">Đang diễn ra</option>
            <option value="DA_KET_THUC">Đã kết thúc</option>
            <option value="DA_HUY">Đã hủy</option>
        </select>

        <select id="regFilter">
            <option value="">Tất cả trạng thái đăng ký</option>
            <option value="CHUA_MO">Chưa mở</option>
            <option value="DANG_MO">Đang mở</option>
            <option value="DA_DONG">Đã đóng</option>
        </select>

        <input type="date" id="fromDate" aria-label="Từ ngày" />
        <input type="date" id="toDate" aria-label="Đến ngày" />

        <button id="btnRefresh" class="btn" type="button">Làm mới</button>
    </section>

    <div class="tournaments-table-wrap">
        <table class="tournaments-table">
            <thead>
                <tr>
                    <th>Mã</th>
                    <th>Tên giải đấu</th>
                    <th>Thời gian</th>
                    <th>Địa điểm</th>
                    <th>Quy mô</th>
                    <th>Trạng thái</th>
                    <th>Đăng ký</th>
                    <th></th>
                </tr>
            </thead>
            <tbody id="tbody">
                <tr>
                    <td colspan="8" class="empty">Đang tải dữ liệu...</td>
                </tr>
            </tbody>
        </table>
    </div>

    <p class="tournament-message" id="pageMessage" role="status"></p>
</section>

<div class="tournament-modal hidden" id="tournamentModal" aria-hidden="true">
    <div class="modal-content" role="dialog" aria-modal="true" aria-labelledby="modalTitle">
        <div class="modal-head">
            <h2 id="modalTitle">Tạo giải đấu</h2>
            <button id="m_close" class="icon" type="button" aria-label="Đóng">×</button>
        </div>

        <div class="tournament-grid">
            <div class="colspan">
                <label for="m_name">Tên giải đấu</label>
                <input id="m_name" placeholder="VD: Giải bóng chuyền IUH 2026" />
            </div>

            <div>
                <label for="m_start">Ngày bắt đầu</label>
                <input id="m_start" type="date" />
            </div>

            <div>
                <label for="m_end">Ngày kết thúc</label>
                <input id="m_end" type="date" />
            </div>

            <div class="colspan">
                <label for="m_place">Địa điểm</label>
                <input id="m_place" placeholder="VD: Nhà thi đấu IUH" />
            </div>

            <div>
                <label for="m_size">Quy mô (số đội)</label>
                <input id="m_size" type="number" min="1" value="8" />
            </div>

            <div>
                <label for="m_image">Ảnh (URL) tùy chọn</label>
                <input id="m_image" placeholder="https://..." />
            </div>

            <div class="colspan">
                <label for="m_desc">Mô tả</label>
                <textarea id="m_desc" rows="3" placeholder="Mô tả ngắn về giải đấu..."></textarea>
            </div>

            <div>
                <label for="m_rule_title">Tiêu đề điều lệ</label>
                <input id="m_rule_title" placeholder="VD: Điều lệ giải đấu" />
            </div>

            <div class="colspan">
                <label for="m_rule_content">Nội dung điều lệ</label>
                <textarea id="m_rule_content" rows="4" placeholder="Nhập nội dung điều lệ bắt buộc..."></textarea>
            </div>
        </div>

        <div id="m_alert" class="tournament-alert hidden"></div>

        <div class="modal-actions">
            <button id="m_cancel" class="btn" type="button">Hủy</button>
            <button id="m_save" class="btn primary" type="button">Lưu</button>
        </div>
    </div>
</div>

<div class="tournament-modal hidden" id="regModal" aria-hidden="true">
    <div class="modal-content wide" role="dialog" aria-modal="true" aria-labelledby="regTitle">
        <div class="modal-head">
            <div>
                <h2 id="regTitle">Quản lý đăng ký giải đấu</h2>
                <p class="sub" id="r_tourName">-</p>
            </div>
            <button id="r_close" class="icon" type="button" aria-label="Đóng">×</button>
        </div>

        <div class="tournaments-toolbar small">
            <select id="r_status">
                <option value="">Tất cả trạng thái</option>
                <option value="CHO_DUYET">Chờ duyệt</option>
                <option value="DA_DUYET">Đã duyệt</option>
                <option value="TU_CHOI">Từ chối</option>
                <option value="DA_HUY">Đã hủy</option>
            </select>
            <input id="r_q" type="text" placeholder="Tìm đội bóng / HLV" />
        </div>

        <div class="tournaments-table-wrap compact">
            <table class="tournaments-table">
                <thead>
                    <tr>
                        <th>Mã ĐK</th>
                        <th>Đội bóng</th>
                        <th>HLV</th>
                        <th>Ngày đăng ký</th>
                        <th>Trạng thái</th>
                        <th>Lý do từ chối</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody id="r_tbody">
                    <tr>
                        <td colspan="7" class="empty">Đang tải dữ liệu...</td>
                    </tr>
                </tbody>
            </table>
        </div>

        <div class="modal-actions">
            <button id="r_closeBtn" class="btn" type="button">Đóng</button>
        </div>
    </div>
</div>

<div class="tournament-modal hidden" id="rejectModal" aria-hidden="true">
    <div class="modal-content small" role="dialog" aria-modal="true" aria-labelledby="rejectTitle">
        <div class="modal-head">
            <h2 id="rejectTitle">Từ chối đăng ký</h2>
            <button id="rej_close" class="icon" type="button" aria-label="Đóng">×</button>
        </div>

        <p class="sub" id="rej_info">-</p>

        <label for="rej_reason">Lý do từ chối (bắt buộc)</label>
        <textarea id="rej_reason" rows="4" placeholder="VD: Hồ sơ đội chưa đầy đủ..."></textarea>

        <div id="rej_alert" class="tournament-alert hidden"></div>

        <div class="modal-actions">
            <button id="rej_cancel" class="btn" type="button">Hủy</button>
            <button id="rej_confirm" class="btn danger" type="button">Xác nhận từ chối</button>
        </div>
    </div>
</div>
