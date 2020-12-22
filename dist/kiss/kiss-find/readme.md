# kiss-find

`kiss-find` is a little shell script that allows you to search for packages in
every known KISS repository, including ones you haven't added to your `KISS_PATH`.

It was built by [admicos](https://git.ebc.li/admicos), with contributions from @aarng.

## Usage

First, you need to do `kiss-find -u` to download an updated database from github's servers.

You might want to do this every now and then, as it will not update automatically.

After that, you can just run `kiss-find query`, and get all packages containing "query" in their name.

## Database

The tools used to create kiss-find's database are available at [jedahan's kiss-find-db repository][]:

[jedahan's kiss-find-db repository]: https://github.com/jedahan/kiss-find-db

If you want to add your own repository to the database, go there for more information.
