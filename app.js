const express = require('express');
const bodyParser = require('body-parser');
const { exec } = require('child_process');
const fs = require("fs");

const app = express();
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

app.post('/', (req, res) => {
  const payload = req.body;
  const type = payload.before;
  const typeDelete = payload.after;
  const branchFull = payload.ref;
  const branch = branchFull.split('/').pop().toLowerCase();
  const defaultType = '0000000000000000000000000000000000000000';
  const path = `/var/www/ci_build/${branch}`;

  if (typeDelete === defaultType && !payload.checkout_sha) {
    console.log(`Branch ${branch} deleted!`);
    /*
    Do something using the command
    exec(`rm -r ${path}`);
    exec(`rm /etc/nginx/sites-enabled/${branch}.example.ru`);
    exec(`service nginx reload`);
    */
  } else if (type === defaultType) {
    createHost(branch, path);
  } else {
    if (fs.existsSync(path)) {
      console.log(`Branch ${branch} updated`);
      // exec(`cd ${path} && git pull`);
    } else {
      createHost(branch, path);
    }
  }
});

function createHost(branch, path) {
  console.log(`Created new branch ${branch}`);
  /*
  exec(`mkdir ${path}`);
  exec(`git clone --single-branch --branch ${branch} git@gitlab-web.maxidom.ru:Web-Maxidom/www.maxidom.ru.git ${path}`);
  exec(`ln -s /var/www/www.example.ru/htdocs/upload ${path}/upload`); // symlink
  exec(`sed -e 's/$branch/${branch}/g' /opt/gitlab-tasker/task.example.ru > /etc/nginx/sites-enabled/${branch}.example.ru`); // Your nginx template with variable $branch inside
  exec(`chmod -R 777 ${path}`);
  exec(`service nginx reload`);
  */
}

app.listen(3003, () => {
  console.log('Server started on port 3003!');
});
