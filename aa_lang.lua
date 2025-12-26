AA_LANG = {}

AA_LANG.en = {
    error = {
        no_perm = 'You do not have permission.',
        invalid_target = 'Invalid target player.',
        too_far = 'Target is too far.',
        invalid_amount = 'Invalid amount.',
        invalid_item = 'Item not found.',
        inv_full = 'Target inventory is full.',
        cooldown = 'Please wait a moment.',
        black_not_set = 'Black money item is not configured.',
        invalid_model = "Invalid vehicle model.",
        plate_invalid = "Invalid plate.",
        request_expired = "Request expired.",
        request_busy = "Target already has a pending request.",
        spawn_failed = "Vehicle spawn failed.",
        invalid_job = "Job not found.",
        invalid_grade = "Invalid grade."

    },
    success = {
        money_sent = 'Money given successfully.',
        item_sent = 'Item given successfully.',
        car_sent = "Car given successfully.",
        job_given = "Job given successfully."
    },
    ui = {
        menu_title = 'Admin Actions Menu',
        give_money = 'Give Money',
        give_items = 'Give Items',

        money_title = 'Give Money',
        money_type = 'Money Type',
        money_cash = 'Cash',
        money_bank = 'Bank',
        money_black = 'Black Money',
        target_id = 'Target ID',
        amount = 'Amount',

        items_title = 'Give Items',
        item_select = 'Select Item',
        quantity = 'Quantity',

        give_car = "Give Car",
        car_title = "Give Car",
        car_model = "Vehicle Model",
        spawn_now = "Spawn Now",
        custom_plate = "Custom Plate (Optional)",

        give_job = "Set Job",
        job_title = "Set Job",
        job_select = "Select Job",
        job_grade = "Grade"
    }
}

AA_LANG.ar = {
    error = {
        no_perm = 'ما عندك صلاحية.',
        invalid_target = 'الشخص غير صحيح.',
        too_far = 'الشخص بعيد جدًا.',
        invalid_amount = 'الرقم غير صحيح.',
        invalid_item = 'الآيتم غير موجود.',
        inv_full = 'شنطة الشخص ممتلئة.',
        cooldown = 'انتظر شوي.',
        black_not_set = 'آيتم الفلوس السوداء غير مضبوط.',
        invalid_model = "موديل السيارة غير صحيح.",
        plate_invalid = "اللوحة غير صحيحة.",
        request_expired = "انتهت مدة الطلب.",
        request_busy = "الشخص عنده طلب معلّق.",
        spawn_failed = "فشل رسبنة السيارة.",
        invalid_job = "الوظيفة غير موجودة.",
        invalid_grade = "الرتبة غير صحيحة."
    },
    success = {
        money_sent = 'تم إعطاء الفلوس بنجاح.',
        item_sent = 'تم إعطاء الآيتم بنجاح.',
        car_sent = "تم إعطاء السيارة بنجاح.",
        job_given = "تم إعطاء الوظيفة بنجاح."
    },
    ui = {
        menu_title = 'قائمة الدفع',
        give_money = 'إعطاء فلوس',
        give_items = 'إعطاء آيتم',

        money_title = 'إعطاء فلوس',
        money_type = 'نوع الفلوس',
        money_cash = 'كاش',
        money_bank = 'بنك',
        money_black = 'فلوس سوداء',
        target_id = 'آيدي الشخص',
        amount = 'المبلغ',

        items_title = 'إعطاء آيتم',
        item_select = 'اختيار الآيتم',
        quantity = 'الكمية',

        give_car = "إعطاء سيارة",
        car_title = "إعطاء سيارة",
        car_model = "موديل السيارة",
        spawn_now = "رسبن الآن",
        custom_plate = "لوحة مخصصة (اختياري)",

        give_job = "إعطاء وظيفة",
        job_title = "إعطاء وظيفة",
        job_select = "اختيار الوظيفة",
        job_grade = "الرتبة"
    }
}

local function deepGet(t, path)
    local cur = t
    for part in string.gmatch(path or '', '[^%.]+') do
        if type(cur) ~= 'table' then return nil end
        cur = cur[part]
        if cur == nil then return nil end
    end
    return cur
end

local function getLocale()
    if type(Settings) == 'table' and type(Settings.Locale) == 'string' then
        local v = string.lower(Settings.Locale)
        if v == 'ar' or v == 'en' then return v end
    end
    return 'en'
end

function T(path)
    local locale = getLocale()
    local tableForLocale = AA_LANG[locale] or AA_LANG.en
    return tostring(deepGet(tableForLocale, path) or deepGet(AA_LANG.en, path) or path)
end
