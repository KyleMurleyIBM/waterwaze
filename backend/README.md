# Setup
## Installing Dependencies
> All dependencies are listed in version.txt. Requires `Python-3.7` or higher, and `pip`

### Create a Virtual Environment
1. `$ virtualenv <env_name>`
1. `$ source <env_name>/bin/activate`
1. `$ pip install -r requirements.txt`

## Running the Backend API
The Database requires a configuration file to be stored at `backend/utils/db.cfg`. This file is must be added by each user and is ignored by git since it contains the credentials which have access to the database. These credentials can be obtained from a created service-account for the db2 instance.

### Example db.cfg
```conf
[db2_config]
username=<username>
password=<password>
database_name=<db_name>
hostname=<host_name>
port=<port>
```

### Running
1. `$ activate <env_name>`
1. `$ python backend.py`

### Testing
Various functions are available in `backend_tester.py` for performing HTTP requests to the backend running locally. ATM the file needs to be modified to select functionality, but this can be changed in the future with a nice menuing system.

1. `$ activate <env_name>`
1. `$ python backend_tester.py`