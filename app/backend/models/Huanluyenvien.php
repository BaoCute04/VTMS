<?php

declare(strict_types=1);

namespace App\Backend\Models;

use App\Backend\Core\Model;
use Throwable;

final class Huanluyenvien extends Model
{
    public function listForOrganizer(int $organizerId, array $filters = []): array
    {
        [$sql, $bindings] = $this->baseCoachQuery($organizerId, $filters);
        $sql .= ' ORDER BY hlv.idhuanluyenvien DESC';

        $statement = $this->db()->prepare($sql);
        $statement->execute($bindings);

        return $statement->fetchAll();
    }

    public function findForOrganizer(int $organizerId, int $coachId): ?array
    {
        [$sql, $bindings] = $this->baseCoachQuery($organizerId, []);
        $sql .= ' WHERE hlv.idhuanluyenvien = :coach_id LIMIT 1';
        $bindings['coach_id'] = $coachId;

        return $this->first($sql, $bindings);
    }

    public function teamsForCoach(int $coachId): array
    {
        $statement = $this->db()->prepare(
            "SELECT
                db.iddoibong,
                db.tendoibong,
                db.logo,
                db.diaphuong,
                db.mota,
                db.trangthai,
                db.ngaytao,
                db.ngaycapnhat,
                COALESCE(tv.total_members, 0) AS total_members,
                COALESCE(tv.active_members, 0) AS active_members
             FROM Doibong db
             LEFT JOIN (
                SELECT
                    iddoibong,
                    COUNT(*) AS total_members,
                    SUM(CASE WHEN trangthai = 'DANG_THAM_GIA' THEN 1 ELSE 0 END) AS active_members
                FROM Thanhviendoibong
                GROUP BY iddoibong
             ) tv ON tv.iddoibong = db.iddoibong
             WHERE db.idhuanluyenvien = :coach_id
             ORDER BY db.iddoibong DESC"
        );

        $statement->execute(['coach_id' => $coachId]);

        return $statement->fetchAll();
    }

    public function updateQualification(
        int $coachId,
        string $oldStatus,
        string $newStatus,
        ?int $requestId,
        ?string $requestStatus,
        string $reason,
        int $actorAccountId,
        ?string $ipAddress,
        string $systemAction,
        string $logNote
    ): void {
        $db = $this->db();

        try {
            $db->beginTransaction();

            $statement = $db->prepare(
                "UPDATE Huanluyenvien
                 SET trangthai = :new_status
                 WHERE idhuanluyenvien = :coach_id
                   AND trangthai = :old_status"
            );
            $statement->execute([
                'new_status' => $newStatus,
                'coach_id' => $coachId,
                'old_status' => $oldStatus,
            ]);

            if ($statement->rowCount() !== 1) {
                throw new \RuntimeException('COACH_QUALIFICATION_NOT_UPDATED');
            }

            if ($requestId !== null && $requestStatus !== null) {
                $statement = $db->prepare(
                    "UPDATE Yeucauxacnhan
                     SET trangthai = :request_status,
                         ngayxuly = CURRENT_TIMESTAMP,
                         ghichu = :reason
                     WHERE idyeucau = :request_id
                       AND trangthai = 'CHO_DUYET'"
                );
                $statement->execute([
                    'request_status' => $requestStatus,
                    'reason' => $reason,
                    'request_id' => $requestId,
                ]);

                if ($statement->rowCount() === 1) {
                    $this->recordStatusHistory('YEU_CAU_XAC_NHAN', $requestId, 'CHO_DUYET', $requestStatus, $reason, $actorAccountId);
                }
            }

            $this->recordSystemLog($actorAccountId, $systemAction, 'Huanluyenvien', $coachId, $ipAddress, $logNote);

            $db->commit();
        } catch (Throwable $exception) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }

            throw $exception;
        }
    }

    private function baseCoachQuery(int $organizerId, array $filters): array
    {
        $where = [];
        $bindings = ['organizer_id' => $organizerId];

        if (($filters['q'] ?? '') !== '') {
            $where[] = "(hlv.bangcap LIKE :keyword
                OR tk.username LIKE :keyword
                OR tk.email LIKE :keyword
                OR tk.sodienthoai LIKE :keyword
                OR nd.cccd LIKE :keyword
                OR TRIM(CONCAT(COALESCE(nd.hodem, ''), ' ', COALESCE(nd.ten, ''))) LIKE :keyword)";
            $bindings['keyword'] = '%' . $filters['q'] . '%';
        }

        if (($filters['status'] ?? '') !== '') {
            $where[] = 'hlv.trangthai = :status';
            $bindings['status'] = $filters['status'];
        }

        if (($filters['account_status'] ?? '') !== '') {
            $where[] = 'tk.trangthai = :account_status';
            $bindings['account_status'] = $filters['account_status'];
        }

        if (($filters['request_status'] ?? '') !== '') {
            $where[] = 'yc.trangthai = :request_status';
            $bindings['request_status'] = $filters['request_status'];
        }

        if (($filters['request_presence'] ?? '') === 'HAS_REQUEST') {
            $where[] = 'yc.idyeucau IS NOT NULL';
        }

        if (($filters['request_presence'] ?? '') === 'NO_REQUEST') {
            $where[] = 'yc.idyeucau IS NULL';
        }

        if (($filters['from'] ?? '') !== '') {
            $where[] = 'COALESCE(yc.ngaygui, nd.ngaytao) >= :from_date';
            $bindings['from_date'] = $filters['from'] . ' 00:00:00';
        }

        if (($filters['to'] ?? '') !== '') {
            $where[] = 'COALESCE(yc.ngaygui, nd.ngaytao) <= :to_date';
            $bindings['to_date'] = $filters['to'] . ' 23:59:59';
        }

        $sql = "SELECT
                hlv.idhuanluyenvien,
                hlv.idnguoidung,
                hlv.bangcap,
                hlv.kinhnghiem,
                hlv.trangthai,
                nd.idtaikhoan,
                nd.hodem,
                nd.ten,
                TRIM(CONCAT(COALESCE(nd.hodem, ''), ' ', COALESCE(nd.ten, ''))) AS hoten,
                nd.gioitinh,
                nd.ngaysinh,
                nd.quequan,
                nd.diachi,
                nd.avatar,
                nd.cccd,
                nd.ngaytao AS nguoidung_ngaytao,
                nd.ngaycapnhat AS nguoidung_ngaycapnhat,
                tk.username,
                tk.email,
                tk.sodienthoai,
                tk.trangthai AS trangthai_taikhoan,
                yc.idyeucau,
                yc.noidung AS yeucau_noidung,
                yc.trangthai AS yeucau_trangthai,
                yc.ngaygui AS yeucau_ngaygui,
                yc.ngayxuly AS yeucau_ngayxuly,
                yc.ghichu AS yeucau_ghichu,
                COALESCE(yc.ngaygui, nd.ngaytao) AS ngaythamchieu,
                COALESCE(team_stats.total_teams, 0) AS total_teams,
                COALESCE(team_stats.active_teams, 0) AS active_teams
             FROM Huanluyenvien hlv
             JOIN Nguoidung nd ON nd.idnguoidung = hlv.idnguoidung
             JOIN Taikhoan tk ON tk.idtaikhoan = nd.idtaikhoan
             LEFT JOIN (
                SELECT
                    idnguoigui,
                    MAX(idyeucau) AS latest_request_id
                FROM Yeucauxacnhan
                WHERE loainguoigui = 'HUAN_LUYEN_VIEN'
                  AND loainguoinhan = 'BAN_TO_CHUC'
                  AND loaixacnhan = 'XAC_NHAN_HLV'
                  AND idnguoinhan = :organizer_id
                GROUP BY idnguoigui
             ) latest_yc ON latest_yc.idnguoigui = hlv.idhuanluyenvien
             LEFT JOIN Yeucauxacnhan yc ON yc.idyeucau = latest_yc.latest_request_id
             LEFT JOIN (
                SELECT
                    idhuanluyenvien,
                    COUNT(*) AS total_teams,
                    SUM(CASE WHEN trangthai = 'HOAT_DONG' THEN 1 ELSE 0 END) AS active_teams
                FROM Doibong
                GROUP BY idhuanluyenvien
             ) team_stats ON team_stats.idhuanluyenvien = hlv.idhuanluyenvien";

        if ($where !== []) {
            $sql .= ' WHERE ' . implode(' AND ', $where);
        }

        return [$sql, $bindings];
    }

    private function recordSystemLog(?int $accountId, string $action, string $targetTable, ?int $targetId, ?string $ipAddress, ?string $note = null): void
    {
        $statement = $this->db()->prepare(
            "INSERT INTO Nhatkyhethong (idtaikhoan, hanhdong, bangtacdong, iddoituong, ipaddress, ghichu)
             VALUES (:account_id, :action, :target_table, :target_id, :ip_address, :note)"
        );

        $statement->execute([
            'account_id' => $accountId,
            'action' => $action,
            'target_table' => $targetTable,
            'target_id' => $targetId,
            'ip_address' => $ipAddress,
            'note' => $note,
        ]);
    }

    private function recordStatusHistory(string $targetType, int $targetId, ?string $oldStatus, string $newStatus, ?string $reason, ?int $actorId): void
    {
        $statement = $this->db()->prepare(
            "INSERT INTO Nhatkytrangthai (loaidoituong, iddoituong, trangthaicu, trangthaimoi, lydo, idnguoithuchien)
             VALUES (:target_type, :target_id, :old_status, :new_status, :reason, :actor_id)"
        );

        $statement->execute([
            'target_type' => $targetType,
            'target_id' => $targetId,
            'old_status' => $oldStatus,
            'new_status' => $newStatus,
            'reason' => $reason,
            'actor_id' => $actorId,
        ]);
    }
}
