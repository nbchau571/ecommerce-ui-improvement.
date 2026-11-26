// Điền 2 giá trị lấy ở Supabase → Project Settings → API.
// Anon key là khoá công khai, được bảo vệ bởi RLS trong schema.sql → có thể commit lên Git.
// TUYỆT ĐỐI không dán service_role key vào đây.
window.APP_CONFIG = {
SUPABASE_URL: "https://qomnvoyjygjkloccbfkx.supabase.co",
SUPABASE_ANON_KEY: "sb_publishable_5cElU6z3MqzJrjdtEhGYig_BrixVvHH"
};
// Để trống → app chạy chế độ ngoại tuyến (lưu trong trình duyệt).
