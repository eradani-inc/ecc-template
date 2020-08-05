# Eradani Connect Client Template

Eradani Connect template application for the *Eradani Connect Client*.

## Installing the template

##### 1. Download and extract source on IBM i

Download the `ecc-template-3.3.x.zip` or `ecc-template-3.3.x.tar.gz` file to your PC then either FTP or SCP the file to the IBM i. Unzip or untar the package into the IFS directory in which you would like it to reside.

##### 2. Remove existing libraries

If a previous version of *Eradani Connect Client* was installed, delete the `ECNCT` library provided the *Eradani Connect Server* is not installed on the same machine. If the server is installed you will have to either manually delete the previous versions of the *Eradani Connect Client* objects or delete the whole library and recreate the server's objects.

If a previous version of the *Eradani Connect Client Template* was installed, delete the `ECNCTAPP` library.

##### 3. Install JavaScript dependencies

`cd` to the extracted `ecc-template-3.3.x` directory and run `npm install`.

##### 4.  Create JavaScript config file

Create the `development.json` configuration file to override default configuration options. The only required override is the `weather.apikey` field. For example:

```json
{
  "weather": {
    "apikey": "00000000000000000000000000000000"
  }
}
```

##### 5. Create the logs directory

`mkdir logs`

##### 6. Create the IBM i objects

```shell
make TGTRLS=V7R3M0 -C node_modules/\@eradani-inc/ec-client/native library
make TGTRLS=V7R3M0 -C node_modules/\@eradani-inc/ec-client/native
make TGTRLS=V7R3M0 -C native library
make TGTRLS=V7R3M0 -C native
```

Where `TGTRLS` is set to the version of your IBM i OS.

## Running the sample programs

To run the sample applications perform the following steps:

##### 1. Start the node.js server

Using your ssh client, `cd` to the extracted `ecc-template-3.3.x` directory and run:

```shell
node src/server
```

##### 2. Add the library

Add the sample application's library to your library list:

```
ADDLIBLE ECNCTAPP
```

##### 3. Run the sample commands

```
DSPJKC
DSPJKR
DSPWFR
```

Run `WRKSPLF` to view the output of the RPG programs.
