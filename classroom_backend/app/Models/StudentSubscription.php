<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class StudentSubscription extends Model
{
    protected $fillable = [
        'student_mobile', 'subjectname', 'teacher_mobile', 'valid_from', 'valid_to', 'status'
    ];

    protected $casts = [
        'valid_from' => 'datetime',
        'valid_to'   => 'datetime',
    ];
}