<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ClassroomSubjectDetail extends Model
{
    //
    protected $table = 'classroomsubjectdetails';
    protected $fillable = [
        'classroomid','classroomname','classroommobile',
        'subjectname','subjectstarttime','subjectduration',
        'subjectendtime','status','zego_room_id','zego_started_at','zego_ended_at'

    ];
    protected $casts = [
    'subjectstarttime' => 'datetime',
    'subjectendtime'   => 'datetime',
    'zego_started_at'  => 'datetime',
    'zego_ended_at'    => 'datetime',
    ];

}
