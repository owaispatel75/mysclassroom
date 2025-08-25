<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class OtpVerification extends Model
{
    //
    protected $fillable = ['mobile','otp','expires_at','verified'];
    protected $casts = ['expires_at' => 'datetime','verified' => 'boolean'];
}
