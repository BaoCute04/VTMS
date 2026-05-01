<?php

declare(strict_types=1);

namespace App\Backend\Models;

use App\Backend\Core\Model;

final class Taikhoan extends Model
{
    public function findByIdentifier(string $identifier): ?array
    {
        return $this->first(
            "SELECT
                tk.idtaikhoan,
                tk.username,
                tk.password,
                tk.email,
                tk.trangthai,
                r.namerole AS role,
                nd.hodem,
                nd.ten
            FROM Taikhoan tk
            JOIN Role r ON r.idrole = tk.idrole
            LEFT JOIN Nguoidung nd ON nd.idtaikhoan = tk.idtaikhoan
            WHERE tk.username = :username
               OR tk.email = :email
            LIMIT 1",
            [
                'username' => $identifier,
                'email' => $identifier,
            ]
        );
    }

    public function findByUsername(string $username): ?array
    {
        return $this->findByIdentifier($username);
    }

    public function findActiveByUsername(string $username): ?array
    {
        return $this->first(
            "SELECT
                tk.idtaikhoan,
                tk.username,
                tk.password,
                tk.email,
                tk.trangthai,
                r.namerole AS role,
                nd.hodem,
                nd.ten
            FROM Taikhoan tk
            JOIN Role r ON r.idrole = tk.idrole
            LEFT JOIN Nguoidung nd ON nd.idtaikhoan = tk.idtaikhoan
            WHERE tk.username = :username
              AND tk.trangthai = 'HOAT_DONG'
            LIMIT 1",
            ['username' => $username]
        );
    }

    public function createLoginSession(int $accountId, string $token): void
    {
        $statement = $this->db()->prepare(
            "INSERT INTO Phiendangnhap (idtaikhoan, token, trangthai)
             VALUES (:account_id, :token, 'DANG_HOAT_DONG')"
        );

        $statement->execute([
            'account_id' => $accountId,
            'token' => $token,
        ]);
    }

    public function closeLoginSession(string $token): void
    {
        $statement = $this->db()->prepare(
            "UPDATE Phiendangnhap
             SET trangthai = 'DA_DANG_XUAT',
                 thoigiandangxuat = CURRENT_TIMESTAMP
             WHERE token = :token
               AND trangthai = 'DANG_HOAT_DONG'"
        );

        $statement->execute(['token' => $token]);
    }

    public function recordLoginHistory(int $accountId, string $result, ?string $ipAddress, ?string $device, ?string $note = null): void
    {
        $statement = $this->db()->prepare(
            "INSERT INTO Lichsudangnhap (idtaikhoan, ipaddress, thietbi, ketqua, ghichu)
             VALUES (:account_id, :ip_address, :device, :result, :note)"
        );

        $statement->execute([
            'account_id' => $accountId,
            'ip_address' => $ipAddress,
            'device' => $device,
            'result' => $result,
            'note' => $note,
        ]);
    }
}
