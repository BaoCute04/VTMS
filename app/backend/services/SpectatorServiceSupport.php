<?php

declare(strict_types=1);

namespace App\Backend\Services;

use App\Backend\Core\Http\Request;
use App\Backend\Models\Nguoidung;

abstract class SpectatorServiceSupport
{
    protected Nguoidung $users;

    public function __construct(?Nguoidung $users = null)
    {
        $this->users = $users ?? new Nguoidung();
    }

    protected function commonFilters(array $filters, array $statuses = []): array
    {
        $errors = [];
        $status = strtoupper(trim((string) ($filters['status'] ?? $filters['trangthai'] ?? '')));
        $from = trim((string) ($filters['from'] ?? $filters['from_date'] ?? $filters['tungay'] ?? ''));
        $to = trim((string) ($filters['to'] ?? $filters['to_date'] ?? $filters['denngay'] ?? ''));

        if ($status !== '' && $statuses !== [] && !in_array($status, $statuses, true)) {
            $errors['status'] = 'Trang thai khong hop le.';
        }

        if ($from !== '' && !$this->isDate($from)) {
            $errors['from'] = 'Tu ngay khong hop le.';
        }

        if ($to !== '' && !$this->isDate($to)) {
            $errors['to'] = 'Den ngay khong hop le.';
        }

        if ($from !== '' && $to !== '' && $this->isDate($from) && $this->isDate($to) && $to < $from) {
            $errors['to'] = 'Den ngay phai lon hon hoac bang tu ngay.';
        }

        return [[
            'q' => trim((string) ($filters['q'] ?? $filters['keyword'] ?? '')),
            'status' => $status,
            'from' => $from,
            'to' => $to,
            'tournament_id' => $this->positiveIntOrNull($filters['tournament_id'] ?? $filters['idgiaidau'] ?? null),
            'team_id' => $this->positiveIntOrNull($filters['team_id'] ?? $filters['iddoibong'] ?? null),
            'match_id' => $this->positiveIntOrNull($filters['match_id'] ?? $filters['idtrandau'] ?? null),
            'venue_id' => $this->positiveIntOrNull($filters['venue_id'] ?? $filters['idsandau'] ?? null),
        ], $errors];
    }

    protected function positiveIntOrNull(mixed $value): ?int
    {
        $raw = trim((string) ($value ?? ''));

        if ($raw === '' || !ctype_digit($raw)) {
            return null;
        }

        $id = (int) $raw;

        return $id > 0 ? $id : null;
    }

    protected function isDate(string $value): bool
    {
        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $value)) {
            return false;
        }

        [$year, $month, $day] = array_map('intval', explode('-', $value));

        return checkdate($month, $day, $year);
    }

    protected function recordView(
        int $accountId,
        string $action,
        string $targetTable,
        ?int $targetId,
        ?Request $request,
        string $note
    ): void {
        $this->users->recordSystemLog(
            $accountId,
            $action,
            $targetTable,
            $targetId,
            $request?->ip(),
            $this->limitLogNote($note)
        );
    }

    protected function limitLogNote(string $note): string
    {
        if (strlen($note) <= 1000) {
            return $note;
        }

        return substr($note, 0, 997) . '...';
    }

    protected function failure(string $message, int $status, array $errors = []): array
    {
        return [
            'ok' => false,
            'status' => $status,
            'message' => $message,
            'errors' => $errors,
        ];
    }
}
