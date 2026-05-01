<?php

declare(strict_types=1);

namespace App\Backend\Services;

use App\Backend\Core\Auth\Auth;
use App\Backend\Core\Http\Request;
use App\Backend\Models\Taikhoan;

final class AuthService
{
    public function attempt(string $username, string $password, ?Request $request = null): array
    {
        $username = trim($username);

        if ($username === '' || $password === '') {
            return $this->result(false, 'Vui long nhap ten dang nhap va mat khau.', 422);
        }

        $accounts = new Taikhoan();
        $account = $accounts->findByIdentifier($username);

        if ($account === null) {
            return $this->result(false, 'Ten dang nhap hoac mat khau khong dung.', 401);
        }

        $accountId = (int) $account['idtaikhoan'];

        if ((string) $account['trangthai'] !== 'HOAT_DONG') {
            $accounts->recordLoginHistory($accountId, 'THAT_BAI', $request?->ip(), $request?->userAgent(), 'Tai khoan khong hoat dong');
            return $this->result(false, 'Tai khoan khong duoc phep dang nhap.', 403);
        }

        if (!password_verify($password, (string) $account['password'])) {
            $accounts->recordLoginHistory($accountId, 'THAT_BAI', $request?->ip(), $request?->userAgent(), 'Sai mat khau');
            return $this->result(false, 'Ten dang nhap hoac mat khau khong dung.', 401);
        }

        $sessionToken = bin2hex(random_bytes(32));
        $accounts->createLoginSession($accountId, $sessionToken);
        $accounts->recordLoginHistory($accountId, 'THANH_CONG', $request?->ip(), $request?->userAgent(), 'Dang nhap thanh cong');

        $user = $this->sessionUser($account);
        Auth::login($user, $sessionToken);

        return $this->result(true, 'Dang nhap thanh cong.', 200, $user);
    }

    public function logout(): void
    {
        $sessionToken = Auth::sessionToken();

        if ($sessionToken !== null) {
            (new Taikhoan())->closeLoginSession($sessionToken);
        }

        Auth::logout();
    }

    private function sessionUser(array $account): array
    {
        $name = trim((string) (($account['hodem'] ?? '') . ' ' . ($account['ten'] ?? '')));

        return [
            'id' => (int) $account['idtaikhoan'],
            'username' => (string) $account['username'],
            'name' => $name !== '' ? $name : (string) $account['username'],
            'email' => (string) $account['email'],
            'role' => (string) $account['role'],
        ];
    }

    private function result(bool $ok, string $message, int $status, ?array $user = null): array
    {
        return [
            'ok' => $ok,
            'message' => $message,
            'status' => $status,
            'user' => $user,
        ];
    }
}
