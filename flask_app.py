import os
from flask import Flask, render_template

app = Flask(__name__)

def find_app_version():
    app_version_filepath = './VERSION'
    with open(app_version_filepath, 'r', encoding='utf8') as file:
        # Assuming the __version__ line is the first line
        return file.readline().strip().split('=')[1].strip().replace("'", "").replace('"', '')

@app.route('/')
def index():
    env = os.environ.get('ENV')
    if env == 'dev':
        firewatch_url = 'http://127.0.0.1:5071'
    elif env == 'stg':
        firewatch_url = 'https://firewatch.kalpataru-grove-stg.dharma.cl'
    else:
        firewatch_url = 'https://firewatch.kalpataru-grove.info'
    app_version = find_app_version()
    return render_template('index.html', firewatch_url=firewatch_url, app_version=app_version)

@app.route('/system_diagram')
def system_diagram():
    return render_template('system_diagram.html')

if __name__ == '__main__':
    app.run(debug=True)
