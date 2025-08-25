<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class ClassroomUsersSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        DB::table('classroomusers')->updateOrInsert(
            ['mobile' => '9998887777'],
         ['fullname' => 'Teacher One', 'role' => 'teacher','email' => 'teacher1@example.com']
        );

        DB::table('classroomusers')->updateOrInsert(
            ['mobile' => '8887776666'],
            ['fullname' => 'Student One', 'role' => 'student','email' => 'student1@example.com']
        );
        DB::table('classroomusers')->updateOrInsert(
            ['mobile' => '7776665555'],
            ['fullname' => 'Admin One', 'role' => 'admin','email' => 'admin1@example.com']
        );
        //
    }
}
