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

### Run the task

This will do the following:

- Delete all upcoming support rota bookings in Productive,
- Fetch all support rota info from the API, importing them into Productive as a booking against the Support project
  for the appropriate person.

```bash
bundle exec rake support_rota_to_productive:import:run
```

### Dry run

If you want to test the tool first, you can do a dry run, which will output the logs, but not
carry out any destructive actions like so.

```bash
bundle exec rake support_rota_to_productive:import:dry_run
```
