import pyodbc
import pandas as pd
from typing import List, Dict, Any, Optional, Tuple


class DatabaseManager:
    """SQL Server veritabanı yönetim sınıfı"""

    def __init__(self, server: str, database: str, username: str = None, password: str = None):
        """
        Veritabanı bağlantısını başlat

        Args:
            server: SQL Server adresi (örn: 'localhost' veya '192.168.1.10')
            database: Veritabanı adı
            username: Kullanıcı adı (None ise Windows Authentication)
            password: Şifre
        """
        self.server = server
        self.database = database
        self.username = username
        self.password = password
        self.connection = None

    def connect(self):
        """Veritabanına bağlan"""
        try:
            if self.username and self.password:
                # SQL Server Authentication
                connection_string = (
                    f"DRIVER={{ODBC Driver 17 for SQL Server}};"
                    f"SERVER={self.server};"
                    f"DATABASE={self.database};"
                    f"UID={self.username};"
                    f"PWD={self.password}"
                )
            else:
                # Windows Authentication
                connection_string = (
                    f"DRIVER={{ODBC Driver 17 for SQL Server}};"
                    f"SERVER={self.server};"
                    f"DATABASE={self.database};"
                    f"Trusted_Connection=yes;"
                )

            self.connection = pyodbc.connect(connection_string)
            return self.connection
        except pyodbc.Error as e:
            print(f"Bağlantı hatası: {e}")
            raise

    def disconnect(self):
        """Veritabanı bağlantısını kapat"""
        if self.connection:
            self.connection.close()
            self.connection = None

    def execute_query(self, query: str, params: Optional[Tuple] = None) -> List[Dict[str, Any]]:
        """
        SELECT sorgusu çalıştır ve sonuçları dictionary listesi olarak döndür

        Args:
            query: SQL sorgusu
            params: Sorgu parametreleri (opsiyonel)

        Returns:
            Sonuç satırlarını içeren dictionary listesi
        """
        conn = self.connect()
        cursor = conn.cursor()

        try:
            if params:
                cursor.execute(query, params)
            else:
                cursor.execute(query)

            # Sütun isimlerini al
            columns = [column[0] for column in cursor.description]

            # Sonuçları dictionary'ye çevir
            results = []
            for row in cursor.fetchall():
                results.append(dict(zip(columns, row)))

            return results

        except pyodbc.Error as e:
            print(f"Sorgu hatası: {e}")
            raise
        finally:
            cursor.close()
            self.disconnect()

    def execute_scalar(self, query: str, params: Optional[Tuple] = None) -> Any:
        """
        Tek bir değer döndüren sorgu çalıştır (COUNT, SUM gibi)

        Args:
            query: SQL sorgusu
            params: Sorgu parametreleri (opsiyonel)

        Returns:
            Tek bir değer
        """
        conn = self.connect()
        cursor = conn.cursor()

        try:
            if params:
                cursor.execute(query, params)
            else:
                cursor.execute(query)

            result = cursor.fetchone()
            return result[0] if result else None

        except pyodbc.Error as e:
            print(f"Sorgu hatası: {e}")
            raise
        finally:
            cursor.close()
            self.disconnect()

    def execute_update(self, query: str, params: Optional[Tuple] = None) -> int:
        """
        INSERT, UPDATE, DELETE sorgusu çalıştır

        Args:
            query: SQL sorgusu
            params: Sorgu parametreleri (opsiyonel)

        Returns:
            Etkilenen satır sayısı
        """
        conn = self.connect()
        cursor = conn.cursor()

        try:
            if params:
                cursor.execute(query, params)
            else:
                cursor.execute(query)

            conn.commit()
            return cursor.rowcount

        except pyodbc.Error as e:
            conn.rollback()
            print(f"Güncelleme hatası: {e}")
            raise
        finally:
            cursor.close()
            self.disconnect()

    # def execute_procedure(self, proc_name: str, params: Optional[Tuple] = None) -> List[Dict[str, Any]]:
    #     """
    #     Stored procedure çalıştır
    #
    #     Args:
    #         proc_name: Stored procedure adı
    #         params: Prosedür parametreleri (opsiyonel)
    #
    #     Returns:
    #         Sonuç satırlarını içeren dictionary listesi
    #     """
    #     conn = self.connect()
    #     cursor = conn.cursor()
    #
    #     try:
    #         # Parametre sayısına göre placeholder oluştur
    #         if params:
    #             placeholders = ', '.join(['?' for _ in params])
    #             query = f"EXEC {proc_name} {placeholders}"
    #             cursor.execute(query, params)
    #         else:
    #             cursor.execute(f"EXEC {proc_name}")
    #
    #         # Eğer sonuç dönüyorsa al
    #         if cursor.description:
    #             columns = [column[0] for column in cursor.description]
    #             results = []
    #             for row in cursor.fetchall():
    #                 results.append(dict(zip(columns, row)))
    #             return results
    #         else:
    #             conn.commit()
    #             return []
    #
    #     except pyodbc.Error as e:
    #         conn.rollback()
    #         print(f"Prosedür hatası: {e}")
    #         raise
    #     finally:
    #         cursor.close()
    #         self.disconnect()

    def execute_procedure(self, proc_name: str, params: Optional[Tuple] = None) -> List[Dict[str, Any]]:
        conn = self.connect()
        cursor = conn.cursor()
        try:
            if params:
                placeholders = ', '.join(['?' for _ in params])
                query = f"EXEC {proc_name} {placeholders}"
                cursor.execute(query, params)
            else:
                cursor.execute(f"EXEC {proc_name}")

            # --- BU KISIM ÇOK ÖNEMLİ ---
            conn.commit()  # Veriyi kalıcı hale getir

            if cursor.description:
                columns = [column[0] for column in cursor.description]
                results = [dict(zip(columns, row)) for row in cursor.fetchall()]
                return results
            return []
        except pyodbc.Error as e:
            conn.rollback()  # Hata varsa geri al
            print(f"Prosedür hatası: {e}")
            raise
        finally:
            cursor.close()
            self.disconnect()





    def get_dataframe(self, query: str, params: Optional[Tuple] = None) -> pd.DataFrame:
        """
        Sorgu sonucunu pandas DataFrame olarak döndür

        Args:
            query: SQL sorgusu
            params: Sorgu parametreleri (opsiyonel)

        Returns:
            Pandas DataFrame
        """
        conn = self.connect()

        try:
            if params:
                df = pd.read_sql(query, conn, params=params)
            else:
                df = pd.read_sql(query, conn)

            return df

        except Exception as e:
            print(f"DataFrame oluşturma hatası: {e}")
            raise
        finally:
            self.disconnect()

    def bulk_insert(self, table_name: str, data: List[Dict[str, Any]]) -> int:
        """
        Toplu veri ekleme (daha hızlı)

        Args:
            table_name: Tablo adı
            data: Eklenecek veriler (dictionary listesi)

        Returns:
            Eklenen satır sayısı
        """
        if not data:
            return 0

        conn = self.connect()
        cursor = conn.cursor()

        try:
            # İlk satırdan sütun isimlerini al
            columns = list(data[0].keys())
            placeholders = ', '.join(['?' for _ in columns])
            column_names = ', '.join(columns)

            query = f"INSERT INTO {table_name} ({column_names}) VALUES ({placeholders})"

            # Verileri tuple listesine çevir
            values = [tuple(row[col] for col in columns) for row in data]

            cursor.executemany(query, values)
            conn.commit()

            return cursor.rowcount

        except pyodbc.Error as e:
            conn.rollback()
            print(f"Toplu ekleme hatası: {e}")
            raise
        finally:
            cursor.close()
            self.disconnect()

    def test_connection(self) -> bool:
        """
        Bağlantıyı test et

        Returns:
            Başarılıysa True, değilse False
        """
        try:
            conn = self.connect()
            cursor = conn.cursor()
            cursor.execute("SELECT 1")
            cursor.fetchone()
            cursor.close()
            self.disconnect()
            print("✓ Veritabanı bağlantısı başarılı!")
            return True
        except Exception as e:
            print(f"✗ Veritabanı bağlantısı başarısız: {e}")
            return False


# Test fonksiyonu
# database.py dosyasının en sonundaki test kısmı:
if __name__ == "__main__":
    db = DatabaseManager(
        server='localhost\\SQLEXPRESS',
        database='ProjectManagementDB2',
        username=None,
        password=None
    )

    # Bağlantı testi
    if db.test_connection():
        # Örnek sorgu
        projects = db.execute_query("SELECT TOP 5 * FROM Projects")
        print("\nİlk 5 Proje:")
        for project in projects:
            print(f"- {project['project_name']}")