<?php

declare(strict_types=1);

namespace App\Backend\Services\Spectator;

use App\Backend\Core\Http\Request;
use App\Backend\Models\Doibong;
use App\Backend\Models\Nguoidung;
use Throwable;

final class SpectatorTeamListService extends SpectatorServiceSupport
{
    private Doibong $teams;

    public function __construct(?Doibong $teams = null, ?Nguoidung $users = null)
    {
        parent::__construct($users);
        $this->teams = $teams ?? new Doibong();
    }

    public function all(int $accountId, array $filters = [], ?Request $request = null): array
    {
        [$normalized, $errors] = $this->commonFilters($filters);
        $normalized['local'] = trim((string) ($filters['local'] ?? $filters['diaphuong'] ?? ''));

        if ($errors !== []) {
            return $this->failure('Bo loc danh sach doi bong khong hop le.', 422, $errors);
        }

        try {
            $teams = $this->teams->listForSpectator($normalized);
            $this->recordView(
                $accountId,
                'Khan gia xem danh sach doi bong',
                'Doibong',
                null,
                $request,
                sprintf('Khan gia #%d xem %d doi bong cong khai.', $accountId, count($teams))
            );

            return [
                'ok' => true,
                'status' => 200,
                'message' => 'Lay danh sach doi bong thanh cong.',
                'teams' => $teams,
                'meta' => [
                    'filters' => $normalized,
                ],
            ];
        } catch (Throwable) {
            return $this->failure('Khong the lay danh sach doi bong.', 500, [
                'database' => 'Loi doc co so du lieu hoac ghi nhat ky.',
            ]);
        }
    }
}

