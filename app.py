######################################################################
from flask import Flask, render_template, request, redirect, url_for, jsonify, g, session
import mysql.connector
import logging

# # Configure logging to record errors and debugging information
# logging.basicConfig(filename='error.log', level=logging.DEBUG,
#                     format='%(asctime)s %(levelname)s %(message)s')

app = Flask(__name__)
app.secret_key = '12345Jigar@#10jigx04'  

db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': '',
    'database': 'ipl'  
}

def get_db():
    if 'db' not in g:
        g.db = mysql.connector.connect(**db_config)
    return g.db

# Function to get a cursor for executing SQL queries
def get_cursor():
    return get_db().cursor()

# Function to fetch the schema (column information) of a table
def get_table_schema(table):
    cursor = get_cursor()
    cursor.execute(f"DESCRIBE {table}")
    schema = cursor.fetchall()
    cursor.close()
    return schema

# Function to get the name of the primary key column for a table
def get_primary_key(table):
    cursor = get_cursor()
    cursor.execute(f"SHOW KEYS FROM {table} WHERE Key_name = 'PRIMARY'")
    primary_key = cursor.fetchone()
    cursor.close()
    return primary_key[4] if primary_key else None

# Teardown function to close the database connection after each request
@app.teardown_appcontext
def teardown_appcontext(exception):
    db = g.pop('db', None)
    if db is not None:
        db.close()

# Route to handle user-submitted SQL queries
@app.route('/query', methods=['POST'])
def query():
    user_query = request.form['query']
    try:
        cursor = get_cursor()
        cursor.execute(user_query)
        columns = [column[0] for column in cursor.description]  # Get column names
        result = cursor.fetchall()
        result_json = [dict(zip(columns, row)) for row in result]  # Create dictionaries
        cursor.close()
        return jsonify(result=result_json)
    except Exception as e:
        app.logger.error(f"Error in query route: {str(e)}")
        return jsonify(error=str(e))

# Route to handle table selection for CRUD operations and viewing content
@app.route('/', methods=['GET', 'POST'])
def select_table():
    if request.method == 'POST':
        if 'crud_table' in request.form:  # Check which form was submitted
            table = request.form['crud_table']
            return redirect(url_for('crud_operations', table=table))
        else:
            table = request.form['table']
            return redirect(url_for('display_table', table=table))
    else:
        cursor = get_cursor()
        cursor.execute("SHOW TABLES")
        tables = [row[0] for row in cursor.fetchall()]
        cursor.close()
        return render_template('select_table.html', tables=tables)

# Route for CRUD operations on the selected table
@app.route('/<table>', methods=['GET', 'POST'])
def crud_operations(table):
    try:
        if request.method == 'POST':
            if 'create' in request.form:
                create_record(table)
            elif 'update' in request.form:
                update_record(table)
            elif 'delete' in request.form:
                delete_record(table)

        cursor = get_cursor()
        cursor.execute(f"SELECT * FROM {table}")
        data = cursor.fetchall()
        schema = get_table_schema(table)
        cursor.close()
        return render_template('crud_template.html', table=table, data=data, schema=schema)
    except Exception as e:
        app.logger.error(f"Error in crud_operations route: {str(e)}")
        return str(e)  # Handle exceptions

# Route to display the content of a selected table
@app.route('/display_table/<table>')  # Corrected route
def display_table(table):
    try:
        cursor = get_cursor()
        cursor.execute(f"SELECT * FROM {table}")
        data = cursor.fetchall()
        schema = get_table_schema(table)
        cursor.close()
        return render_template('crud_template.html', table=table, data=data, schema=schema)
    except Exception as e:
        app.logger.error(f"Error in display_table route: {str(e)}")
        return str(e)

@app.route('/userquery')
def user_query_page():
    return render_template('query.html')


@app.route('/show_er_diagram')
def show_er_diagram():
    return render_template('er.html')

@app.route('/operations')
def operations():
    return render_template('operations.html')

@app.route('/sample_queries')
def sample_queries():
    return render_template('sample.html')

admin_cred={
    'username': 'admin',
    'password': '1234admin'
}

@app.route('/admin_login', methods=['GET', 'POST'])
def admin_login():
    if request.method == 'POST':
        if request.form['username'] == admin_cred['username'] and request.form['password'] == admin_cred['password']:
            session['admin_logged_in'] = True
            return redirect(url_for('admin_page'))
        else:
            return render_template('admin_login.html', error='Invalid credentials')
    return render_template('admin_login.html')

# Admin page for DML operations
@app.route('/admin', methods=['GET', 'POST'])
def admin_page():
    if 'admin_logged_in' not in session or not session['admin_logged_in']:
        return redirect(url_for('admin_login'))

    cursor = get_cursor()
    cursor.execute("SHOW TABLES")
    tables = [row[0] for row in cursor.fetchall()]
    cursor.close()

    if request.method == 'POST':
        table = request.form['table']  # Get the selected table

        if 'create' in request.form:
            create_record(table)
        elif 'update' in request.form:
            update_record(table)
        elif 'delete' in request.form:
            delete_record(table)
        
        schema=get_table_schema(table)
        return render_template('admin.html', tables=tables, schema=schema)

    return render_template('admin.html', tables=tables)

# Function to create a record
def create_record(table):
    cursor = get_cursor()
    schema = get_table_schema(table)
    columns = [row[0] for row in schema if row[3] != 'PRI']  # Exclude primary key
    placeholders = ', '.join(['%s'] * len(columns))
    query = f"INSERT INTO {table} ({', '.join(columns)}) VALUES ({placeholders})"
    values = [request.form.get(col, '') for col in columns]
    cursor.execute(query, values)
    get_db().commit()  # Commit changes to the database
    cursor.close()

# Function to update a record
def update_record(table):
    cursor = get_cursor()
    schema = get_table_schema(table)
    primary_key = get_primary_key(table)
    columns = [row[0] for row in schema if row[3] != 'PRI']  # Exclude primary key
    set_clause = ', '.join([f"{col} = %s" for col in columns])
    query = f"UPDATE {table} SET {set_clause} WHERE {primary_key} = %s"
    values = [request.form.get(col, '') for col in columns]
    values.append(request.form.get(primary_key, ''))  # Add primary key value
    cursor.execute(query, values)
    get_db().commit()  # Commit changes to the database
    cursor.close()

# Function to delete a record
def delete_record(table):
    cursor = get_cursor()
    primary_key = get_primary_key(table)
    query = f"DELETE FROM {table} WHERE {primary_key} = %s"
    record_id = request.form.get(primary_key, '')
    cursor.execute(query, (record_id,))
    get_db().commit()  # Commit changes to the database
    cursor.close()
    


# Logout route for admin
@app.route('/admin_logout')
def admin_logout():
    session.pop('admin_logged_in', None)
    return redirect(url_for('admin_login'))

if __name__ == '__main__':
    app.run(debug=True) 

