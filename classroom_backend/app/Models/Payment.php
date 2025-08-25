<?php
// app/Models/Payment.php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Payment extends Model {
  protected $fillable = [
    'mobile','amount','currency','status','order_id','payment_id',
    'paid_at','period_start','period_end','notes'
  ];
  protected $casts = [
    'paid_at' => 'datetime',
    'period_start' => 'date',
    'period_end' => 'date',
    'notes' => 'array',
  ];
}