# Phương Pháp Tính Điểm & Đổi Thưởng (Reward Calculation & Redemption)

Tài liệu này quy định cách tính điểm tích lũy, cơ chế thăng hạng thành viên và quy tắc đổi thưởng dựa trên dữ liệu từ `menu_items.json` và `rewards.json`.

## 1. Cơ Chế Tích Điểm (Earning Mechanism)

Điểm thưởng được tính dựa trên giá trị thanh toán thực tế của đơn hàng (sau khi trừ khuyến mãi).

### Công Thức
$$
\text{Điểm Tích Lũy} = \left\lfloor \frac{\text{Giá Trị Đơn Hàng}}{1.000} \right\rfloor \times \text{Hệ Số Danh Mục} \times (1 + \text{\% Thưởng Hạng})
$$

### Các Hệ Số (Multipliers)
1.  **Hệ Số Danh Mục (Category Bonus):**
    *   **Combo:** x1.2
    *   **Món Mới (New):** x1.1
    *   **Khác:** x1.0
    *   *(Ưu tiên hệ số cao nhất nếu trùng)*

2.  **Thưởng Hạng Thành Viên (Tier Bonus):**
    *   **Bronze:** 0%
    *   **Silver:** +5%
    *   **Gold:** +10%
    *   **Platinum:** +15%

---

## 2. Hệ Thống Hạng Thành Viên (Tier System)

Hạng thành viên được xác định dựa trên **Tổng Điểm Đã Tích Lũy (Total Earned Points)** từ trước đến nay (không tính điểm đã tiêu dùng).

| Hạng (Tier) | Điểm Yêu Cầu (Total Earned) | Quyền Lợi Tích Điểm |
| :--- | :--- | :--- |
| **New** | 0 điểm | 0% |
| **Bronze** | 1 - 299 điểm | 0% |
| **Silver** | 300 - 999 điểm | +5% |
| **Gold** | 1.000 - 1.999 điểm | +10% |
| **Platinum** | ≥ 2.000 điểm | +15% |

*(Dữ liệu tham khảo từ `rewards.json`)*

---

## 3. Cơ Chế Đổi Thưởng (Redemption Rules)

Thành viên có thể sử dụng **Điểm Hiện Có (Current Points)** để đổi các Voucher tương ứng với hạng của mình hoặc hạng thấp hơn.

### Danh Sách Voucher Theo Hạng
Dựa trên `rewards.json`, các voucher được phân bổ như sau:

#### 🥉 Bronze Tier
*   **Voucher 20K:** Giảm 20.000đ cho đơn từ 100K.
    *   *Chi phí đổi:* 200 điểm (Dự kiến)

#### 🥈 Silver Tier
*   **Voucher 30K:** Giảm 30.000đ cho đơn từ 150K.
*   **Voucher 50K:** Giảm 50.000đ cho đơn từ 200K.
    *   *Chi phí đổi:* 300 - 500 điểm

#### 🥇 Gold Tier
*   **Voucher 100K:** Giảm 100.000đ cho đơn từ 300K.
*   **Free Ship:** Miễn phí giao hàng cho đơn kế tiếp.
    *   *Chi phí đổi:* 800 - 1000 điểm

#### 💎 Platinum Tier
*   **Voucher 200K:** Giảm 200.000đ cho đơn từ 500K.
    *   *Chi phí đổi:* 1500 điểm

### Quy Tắc Đổi
1.  Mỗi lần đổi sẽ trừ số điểm tương ứng vào `points`.
2.  `totalEarned` không bị trừ (để giữ hạng).
3.  Voucher có hạn sử dụng (`expiryDate`) và điều kiện áp dụng (`description`).

---

## 4. Ví Dụ Tính Toán

**Khách hàng hạng Silver mua Combo "The Mega Feast" (199.000đ):**

1.  **Điểm Cơ Bản:** $199.000 / 1.000 = 199$ điểm.
2.  **Hệ Số Combo:** $199 \times 1.2 = 238.8$ điểm.
3.  **Thưởng Hạng Silver (+5%):** $238.8 \times 1.05 = 250.74$ điểm.
4.  **Kết Quả:** Khách hàng nhận được **250 điểm**.

**Cập Nhật Trạng Thái:**
*   `points` tăng thêm 250.
*   `totalEarned` tăng thêm 250.
*   Nếu `totalEarned` vượt qua 1.000, khách hàng thăng hạng **Gold**.
