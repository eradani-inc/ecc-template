# Eradani Connect Client Template

Eradani Connect template application for the *Eradani Connect Client*.

## Installing the template

##### 1. Download and extract source on IBM i

Download the `ecc-template-x.x.x.zip` or `ecc-template-x.x.x.tar.gz` file to your PC then either FTP or SCP the file to the IBM i. Unzip or untar the package into the IFS directory in which you would like it to reside.

##### 2. Remove existing libraries

If a previous version of *Eradani Connect Client* was installed, delete the `ECNCT` library provided the *Eradani Connect Server* is not installed on the same machine. If the server is installed you will have to either manually delete the previous versions of the *Eradani Connect Client* objects or delete the whole library and recreate the server's objects.

If a previous version of the *Eradani Connect Client Template* was installed, delete the `ECNCTAPP` library.

##### 3. Install JavaScript dependencies

`cd` to the extracted `ecc-template-x.x.x` directory and run `npm install`.

##### 4.  Create JavaScript config file

Configuration is based on the popular `config` open source module. A full guide on configuration using this module can be found here: [https://github.com/lorenwest/node-config/wiki](https://github.com/lorenwest/node-config/wiki)

Create the `development.json` configuration file to override default configuration options. The only required override are the `weather.apikey` and `traffic.apikey` fields. Demo API keys can be obtained at, https://openweathermap.org/api and https://www.shipengine.com/. To add the API keys and override other default options add a configure like this in `development.json`:

```json
{
  "weather": {
    "apikey": "00000000000000000000000000000000"
  },
  "traffic": {
      "apiKey": "0000000000000000000000000000000000000000000"
  },
  "ecclient": {
    "debug": true,
    "pooling": false
  }
}
```

The full list of options can be found in `src/config/default.json`.

##### 5. Create the logs directory

`mkdir logs`

##### 6. Create the IBM i objects

```shell
make TGTRLS=V7R3M0 -C node_modules/\@eradani-inc/ec-client/native library
make TGTRLS=V7R3M0 -C node_modules/\@eradani-inc/ec-client/native
make TGTRLS=V7R3M0 -C qsys library
make TGTRLS=V7R3M0 -C qsys
```

Where `TGTRLS` is set to the version of your IBM i OS.

## Running the sample programs

To run the sample applications perform the following steps:

##### 1. Start the node.js server

Using your ssh client, `cd` to the extracted `ecc-template-x.x.x` directory and run:

```shell
node src/server
```

##### 2. Add the library

Add the sample application's library to your library list:

```
ADDLIBLE ECNCTAPP
```

##### 3. Run the sample commands

The template comes with sample commands and RPG programs to demonstrate how to call web services using *Eradani Connect*. The following is a list of commands in the `ECNCTAPP` library:

- `DSPJK`: This command will make a call to the *Internet Chuck Norris Database (ICNDB)*, https://api.icndb.com, and retrieve a random Chuck Norris joke.
- `DSPTRFC`: This command will make make a call to a traffic report web service, https://traffic.ls.hereapi.com, and retrieve the current traffic conditions.
- `DSPVHCL`: This command will make a call to the U.S. Department of Transportation's *NHTSA Product Information Catalog and Vehicle Listing*, https://vpic.nhtsa.dot.gov/api, to retrieve information based on a vehicle identification number.
- `DSPWF`: This command will make a call to the *Open Weather* web service, https://api.openweathermap.org/data/2.5/, and retrieve a weather forecast based on a latitude and longitude.
- `PRTLBL`: This command will make a call to the *ShipEngine* web service, https://api.shipengine.com/v1, and download a PDF of a USPS shipping label based on an address and weight and size information.

Run `WRKSPLF` to view the output of the RPG programs.

Each of the commands above invokes an RPG program of the same name in the `ECNCTAPP` library.
