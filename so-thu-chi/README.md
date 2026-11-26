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
