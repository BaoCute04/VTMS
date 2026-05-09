<?php

declare(strict_types=1);

namespace App\Backend\Services;

use App\Backend\Core\Http\Request;
use App\Backend\Models\Ketquatrandau;
use App\Backend\Models\Nguoidung;
use Throwable;

final class SpectatorMatchResultService extends SpectatorServiceSupport
{
    private Ketquatrandau $results;

    public function __construct(?Ketquatrandau $results = null, ?Nguoidung $users = null)
    {
        parent::__construct($users);
        $this->results = $results ?? new Ketquatrandau();
    }

    public function all(int $accountId, array $filters = [], ?Request $request = null): array
    {
        [$normalized, $errors] = $this->commonFilters($filters);

        if ($errors !== []) {
            return $this->failure('Bo loc ket qua tran dau khong hop le.', 422, $errors);
        }

        try {
            $results = $this->results->listForSpectator($normalized);
            $this->recordView(
                $accountId,
                'Khan gia xem ket qua tran dau',
                'Ketquatrandau',
                null,
                $request,
                sprintf('Khan gia #%d xem %d ket qua da cong bo.', $accountId, count($results))
            );

            return [
                'ok' => true,
                'status' => 200,
                'message' => 'Lay ket qua tran dau thanh cong.',
                'results' => $results,
                'meta' => [
                    'filters' => $normalized,
                    'publish_status' => 'DA_CONG_BO',
                ],
            ];
        } catch (Throwable) {
            return $this->failure('Khong the lay ket qua tran dau.', 500, [
                'database' => 'Loi doc co so du lieu hoac ghi nhat ky.',
            ]);
        }
    }

    public function show(int $resultId, int $accountId, ?Request $request = null): array
    {
        try {
            $result = $this->results->findForSpectator($resultId);

            if ($result === null) {
                return $this->failure('Khong tim thay ket qua tran dau da cong bo.', 404);
            }

            $sets = $this->results->setsForResult($resultId);
            $this->recordView(
                $accountId,
                'Khan gia xem chi tiet ket qua tran dau',
                'Ketquatrandau',
                $resultId,
                $request,
                sprintf('Khan gia #%d xem ket qua #%d.', $accountId, $resultId)
            );

            return [
                'ok' => true,
                'status' => 200,
                'message' => 'Lay chi tiet ket qua tran dau thanh cong.',
                'result' => $result,
                'sets' => $sets,
            ];
        } catch (Throwable) {
            return $this->failure('Khong the lay chi tiet ket qua tran dau.', 500, [
                'database' => 'Loi doc co so du lieu hoac ghi nhat ky.',
            ]);
        }
    }
}
