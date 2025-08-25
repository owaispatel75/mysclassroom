<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Offering extends Model
{
    protected $fillable = [
        'subjectname', 'teacher_mobile', 'price_paise', 'currency', 'active'
    ];
}