# Support Rota to Productive

Imports the dxw [Support Rota](https://dxw-support-rota.herokuapp.com/) into [Productive](https://productive.io).

## Usage

### Clone the repo

```bash
git clone git@github.com:dxw/support-rota-to-productive.git
```

### Install the dependencies

```bash
bundle install
```

### Add the relevant environment variables

Copy `.env.example` to a file called `.env` and fill in the variables with some real info.

- `PRODUCTIVE_API_KEY` a Productive API with read/write permissions
- `PRODUCTIVE_ACCOUNT_ID` the account ID of the Productive organisation, you can
find this in the url of every Productive request
- `SUPPORT_PROJECT_ID` the ID of the project to which support time is added, this
project will need to exist
- `SUPPORT_SERVICE_ID` the ID of the service to which support time is added, this
service will need to exist. Unfortunately there is no simple way to get this,
you have to call the API `
https://api.productive.io/api/v2/services?&filter[project_id]=SUPPORT_PROJECT_ID`
and locate the relevant ID.

### Run the task

This will do the following:

This will fetch all support project bookings from Productive and the Support Rota, deleting any that are
present in Productive, but not the Support Rota, and creating any that are present in the Support Rota,
but not Productive.

```bash
bundle exec rake support_rota_to_productive:import:run
```

### Dry run

If you want to test the tool first, you can do a dry run, which will output the logs, but not
carry out any destructive actions like so.

```bash
bundle exec rake support_rota_to_productive:import:dry_run
```
