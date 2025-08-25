<?php

// namespace App\Http\Controllers\API;

// use App\Http\Controllers\Controller;
// use App\Models\Offering;
// use Illuminate\Http\Request;

// class OfferingController extends Controller
// {
//     public function index(Request $request)
//     {
//         $q = Offering::query()->where('active', true);
//         if ($request->filled('subject')) {
//             $q->where('subjectname', $request->query('subject'));
//         }
//         $rows = $q->orderBy('subjectname')->orderBy('teacher_mobile')->get();

//         return response()->json([
//             'offerings' => $rows->map(fn($o) => [
//                 'id'            => $o->id,
//                 'subject'       => $o->subjectname,
//                 'teacher_mobile'=> $o->teacher_mobile,
//                 'price_paise'   => $o->price_paise,
//                 'currency'      => $o->currency,
//                 'active'        => $o->active,
//             ]),
//         ]);
//     }
// }

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Offering;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
// ✅ Eloquent models you reference:
use App\Models\StudentSubscription;   // <— add this              // (and any others you use)
use App\Models\Subject;

class OfferingController extends Controller
{
    // // GET /api/offerings?subject=...&teacher_mobile=...
    // public function index(Request $request)
    // {
    //     $q = Offering::query()->where('active', true);
    //     if ($s = $request->query('subject'))        $q->where('subjectname', $s);
    //     if ($t = $request->query('teacher_mobile')) $q->where('teacher_mobile', $t);

    //     return response()->json([
    //         'offerings' => $q->orderBy('subjectname')->orderBy('teacher_mobile')->get(),
    //     ]);
    // }

    public function index(Request $request)
    {
        $q = Offering::query()->where('active', true);
        if ($s = $request->query('subject'))        $q->where('subjectname', $s);
        if ($t = $request->query('teacher_mobile')) $q->where('teacher_mobile', $t);

        $items = $q->orderBy('subjectname')->orderBy('teacher_mobile')->get();

        $mobile = $request->query('mobile');
        if ($mobile) {
            $now = Carbon::now();
            $subs = StudentSubscription::where('student_mobile', $mobile)
                ->where('status', 'active')
                ->where('valid_to', '>=', $now)
                ->get()
                ->map(fn ($s) => $s->subjectname.'|'.$s->teacher_mobile)
                ->flip();

            $items = $items->map(function ($o) use ($subs) {
                $arr = $o->toArray();
                $key = $o->subjectname.'|'.$o->teacher_mobile;
                $arr['enrolled'] = $subs->has($key) ? 1 : 0;
                return $arr;
            });
        }

        return response()->json(['offerings' => $items]);
    }


    // POST /api/offerings
    public function store(Request $request)
    {
        $data = $request->validate([
            'subjectname'    => 'required|string|max:120',
            'teacher_mobile' => 'required|string|max:20',
            'price_paise'    => 'required|integer|min:0',
            'currency'       => 'nullable|string|max:10',
            'active'         => 'nullable|boolean',
        ]);

        $off = Offering::create([
            'subjectname'    => $data['subjectname'],
            'teacher_mobile' => $data['teacher_mobile'],
            'price_paise'    => $data['price_paise'],
            'currency'       => $data['currency'] ?? 'INR',
            'active'         => $data['active']   ?? true,
        ]);

        return response()->json(['id' => $off->id, 'offering' => $off], 201);
    }

    // PUT /api/offerings/{id}
    public function update(Request $request, $id)
    {
        $off = Offering::findOrFail($id);
        $data = $request->validate([
            'subjectname'    => 'sometimes|string|max:120',
            'teacher_mobile' => 'sometimes|string|max:20',
            'price_paise'    => 'sometimes|integer|min:0',
            'currency'       => 'sometimes|string|max:10',
            'active'         => 'sometimes|boolean',
        ]);

        $off->update($data);
        return response()->json(['offering' => $off]);
    }

    // DELETE /api/offerings/{id}
    public function destroy($id)
    {
        $off = Offering::findOrFail($id);
        $off->delete();
        return response()->json(['deleted' => true]);
    }
}
