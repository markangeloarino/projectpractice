 const mariadb = require('mariadb');
const bcrypt = require('bcrypt');

async function createAdmin() {
    const pool = mariadb.createPool({
        host: 'localhost', 
        user: 'root', 
        password: '', 
        database: 'neis_db'
    });
    
    let conn;
    try {
        conn = await pool.getConnection();
        
        // 1. Add the missing columns to the table
        console.log("Updating table structure...");
        try {
            await conn.query("ALTER TABLE peso_staff ADD COLUMN email VARCHAR(150) UNIQUE;");
            await conn.query("ALTER TABLE peso_staff ADD COLUMN password_hash VARCHAR(255);");
            await conn.query("ALTER TABLE peso_staff ADD COLUMN role VARCHAR(50) DEFAULT 'Staff';");
        } catch (e) {
            // If the columns already exist, MariaDB will throw a warning, which we can safely ignore
        }

        // 2. Disable foreign key checks temporarily
        await conn.query("SET FOREIGN_KEY_CHECKS = 0;");
        
        // 3. Clear old staff to prevent duplicates
        await conn.query("TRUNCATE TABLE peso_staff;"); 
        
        // 4. Re-enable foreign key checks
        await conn.query("SET FOREIGN_KEY_CHECKS = 1;");

        // 5. Safely hash the passwords
        const salt = await bcrypt.genSalt(10);
        const hashedAdminPassword = await bcrypt.hash('admin123', salt);
        const hashedStaffPassword = await bcrypt.hash('staff123', salt);

        // 6. Insert Admin
        await conn.query(
            "INSERT INTO peso_staff (name, email, password_hash, role) VALUES (?, ?, ?, ?)",
            ['System Admin', 'admin@naga.gov.ph', hashedAdminPassword, 'Admin']
        );
        
        // 7. Insert Staff
        await conn.query(
            "INSERT INTO peso_staff (name, email, password_hash, role) VALUES (?, ?, ?, ?)",
            ['Mediated Entry Officer', 'staff@naga.gov.ph', hashedStaffPassword, 'Staff']
        );

        console.log("Success! Table updated, real hashes generated, and accounts inserted.");
    } catch (err) {
        console.error("Error:", err);
    } finally {
        if (conn) conn.release();
        process.exit();
    }
}

createAdmin();