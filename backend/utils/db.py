from configparser import ConfigParser
from ibm_db import connect, exec_immediate


class DB_Utils():
    def __init__(self):
        self._connect()

    def _connect(self):
        parser = ConfigParser()
        parser.read('./utils/db.cfg')
        username = parser.get('db2_config', 'username')
        password = parser.get('db2_config', 'password')
        database_name = parser.get('db2_config', 'database_name')
        port = parser.get('db2_config', 'port')
        hostname = parser.get('db2_config', 'hostname')

        connection = connect(
            f'DATABASE={database_name};'
            f'HOSTNAME={hostname};'
            f'PORT={port};'
            'PROTOCOL=TCPIP;'
            f'UID={username};'
            f'PWD={password};'
            'Security=SSL;', username, password
        )

        self.connection = connection

    def run_raw_sql(self, sql, request_results=True):
        if request_results:
            return results(exec_immediate(self.connection, sql))
        else:
            return exec_immediate(self.connection, sql)


def results(command):
    from ibm_db import fetch_assoc

    ret = []
    result = fetch_assoc(command)
    while result:
        ret.append(result)
        result = fetch_assoc(command)
    return ret
