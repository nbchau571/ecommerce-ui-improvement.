# Sổ thu chi

Ứng dụng quản lý thu chi (HTML, CSS, JavaScript thuần) kết nối Supabase.
Chức năng: thêm, sửa, xoá giao dịch; đổi trạng thái (Đã xong / Chờ xử lý); thống kê theo danh mục và theo tháng; đăng nhập riêng từng người dùng.

## Cấu trúc

```
so-thu-chi/
├── index.html            # Giao diện + logic
├── config.js             # URL và anon key của Supabase
├── supabase/schema.sql   # Toàn bộ database (bảng, ràng buộc, RLS, view, dữ liệu mặc định)
└── .gitignore
```

## Database

| Bảng / View | Vai trò |
|---|---|
| `categories` | Danh mục thu/chi. `user_id` rỗng là danh mục mặc định, có giá trị là danh mục riêng của người dùng. |
| `transactions` | Giao dịch: `type` (thu/chi), `category_id`, `title`, `amount` (đồng, > 0), `occurred_on`, `status` (done/pending). |
| `v_monthly_summary` | Tổng thu, tổng chi theo tháng (chỉ tính giao dịch `done`). |
| `v_category_summary` | Tổng theo danh mục (chỉ tính giao dịch `done`). |

```
auth.users 1 ──< transactions >── 1 categories
auth.users 1 ──< categories (danh mục riêng, tuỳ chọn)
```

- Khoá ngoại ghép `(category_id, type)` bảo đảm giao dịch "chi" không thể gắn danh mục "thu".
- Row Level Security: mỗi người chỉ đọc và ghi được giao dịch của mình.
- Trigger tự cập nhật `updated_at`.

## Cài đặt

1. Tạo project tại https://supabase.com.
2. Vào **SQL Editor**, dán toàn bộ `supabase/schema.sql` rồi bấm **Run**.
3. Vào **Project Settings → API**, chép **Project URL** và **anon public key** vào `config.js`.
4. (Tuỳ chọn, để thử nhanh) Vào **Authentication → Providers → Email**, tắt "Confirm email" để đăng ký xong dùng được ngay.
5. Chạy thử trên máy:
   ```bash
   npx serve .
   ```
   Mở địa chỉ hiện ra, tạo tài khoản, rồi vào tab **Dữ liệu → Thêm dữ liệu mẫu** nếu muốn có dữ liệu thử.

Nếu `config.js` để trống, app chạy chế độ ngoại tuyến (lưu trong trình duyệt), tiện để xem giao diện.

## Đưa lên Git

```bash
git init
git add .
git commit -m "Sổ thu chi: giao diện + schema Supabase"
git branch -M main
git remote add origin https://github.com/<ten-ban>/so-thu-chi.git
git push -u origin main
```

Có thể deploy miễn phí bằng GitHub Pages (Settings → Pages → Deploy from branch → `main`) hoặc Vercel/Netlify.
Sau khi có địa chỉ website, thêm địa chỉ đó vào **Authentication → URL Configuration → Site URL** trên Supabase.

## Lưu ý bảo mật

- `anon key` công khai được, vì dữ liệu đã được RLS bảo vệ.
- Không đưa `service_role key` vào code hoặc lên Git.
