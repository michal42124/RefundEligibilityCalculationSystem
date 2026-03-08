# מערכת החזרי מס

מערכת web לניהול ועיבוד בקשות להחזרי מס. הפקיד מחפש אזרח לפי תעודת זהות, מחשב את זכאותו, ומאשר או דוחה את הבקשה בהתאם לתקציב החודשי הזמין.

---

## מבנה הפרויקט

```
project/
├── RefundSystem/          # קבצי ה-Backend (.NET)
│   ├── RefundSystem.API/
│   ├── RefundSystem.Core/
│   └── RefundSystem.Infrastructure/
├── refund-client/         # קבצי ה-Frontend (React)
├── DB/                    # סקריפטים למסד הנתונים
│   ├── CreateDatabase.sql
│   └── SeedData.sql
└── README.md
```

---

## טכנולוגיות

- **Backend:** .NET 8, ASP.NET Core Web API
- **ORM:** Entity Framework Core 8
- **מסד נתונים:** SQL Server 2019
- **Frontend:** React 19, TanStack Query 5
- **עדכון בזמן אמת:** SignalR
- **HTTP Client:** Axios
- **ייצוא PDF:** QuestPDF

---

## פיצ'רים עיקריים

### חישוב זכאות
- בדיקת מינימום 6 חודשי הכנסה בשנת המס
- בדיקת העדר בקשה מאושרת קיימת לאותה שנת מס
- בדיקת תקציב חודשי זמין — אם אין תקציב מספיק בחודש הגשת הבקשה, לא ניתן לאשר אותה
- חישוב ממוצע הכנסות לשנת המס
- חישוב החזר מדורג לפי מדרגות הכנסה (Stored Procedures)

### ניהול תקציב
- מניעת הקצאת תקציב כפולה בקריאות מקבילות (UPDLOCK + HOLDLOCK)
- עדכון תקציב בזמן אמת בין פקידים מרובים באמצעות SignalR

### ממשק משתמש
- ממשק פקיד – צפייה בבקשות ממתינות, חישוב זכאות ואישור/דחייה
- ממשק אזרח – צפייה בסטטוס הבקשה והיסטוריית בקשות
- ניהול state ו-caching חכם באמצעות TanStack Query

---

## פיתוחים נוספים שבוצעו

### 1. עדכון תקציב בזמן אמת — SignalR
**תיאור:** כאשר פקיד מאשר בקשה, כל הפקידים הפתוחים על בקשות מאותו חודש רואים את התקציב המעודכן באופן מיידי ללא רענון הדף.  
**מטרה:** מניעת חריגה מהתקציב החודשי במקרה של אישורים במקביל.  
**מימוש:** SignalR WebSockets — השרת משדר עדכון לכל הלקוחות המחוברים בעת אישור בקשה.

### 2. ייצוא דוח PDF לפי שנת מס
**תיאור:** פקיד בוחר שנת מס ומוריד דוח PDF הכולל את כל הבקשות המאושרות לאותה שנה.  
**מטרה:** כלי דיווח ובקרה לפקידים ומנהלים לצרכי ביקורת.  
**מימוש:** ספריית QuestPDF בצד השרת, הורדה כ-Blob מה-Frontend.

---

## הוראות התקנה והרצה

### דרישות מקדימות
- .NET 8 SDK
- SQL Server 2019+
- Node.js – נדרש להרצת סביבת הפיתוח של React

### 1. מסד הנתונים
פתח את SQL Server Management Studio והרץ את הסקריפטים לפי הסדר:
1. `DB/CreateDatabase.sql` — יוצר טבלאות, Stored Procedures ופונקציות
2. `DB/SeedData.sql` — מכניס נתוני דוגמה

### 2. Backend – .NET API
1. עדכן את connection string בקובץ `appsettings.json` תחת `"DefaultConnection"`
2. נווט לתיקיית `RefundSystem.API`
3. הרץ: `dotnet run`
4. ה-API יעלה על: `https://localhost:7047`

### 3. Frontend – React
1. נווט לתיקיית `refund-client`
2. הרץ: `npm install`
3. הרץ: `npm start`
4. האפליקציה תעלה על: `http://localhost:3000`
