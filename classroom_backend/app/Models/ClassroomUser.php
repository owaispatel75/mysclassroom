<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ClassroomUser extends Model
{
    protected $table = 'classroomusers';
    protected $fillable = [
        'fullname','mobile','aadharcardnumber','aadharcard','dob','joiningdate','role','is_logged','device_id','last_login_at','email',
    ];
    protected $casts = [
    'last_login_at' => 'datetime',
    'trial_ends_at' => 'date',
    'paid_until'    => 'date',
    ];

}
