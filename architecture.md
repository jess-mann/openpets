# OpenPets Architecture

Assuming `openpets0menubar` means `openpets-menubar`:

```text
                         External integrations
                    agents / scripts / local tools
                         |                  |
                         | MCP over HTTP    | shell command
                         v                  v
                 +----------------+   +----------------+
                 | MCP clients    |   | openpets CLI   |
                 | Cursor, etc.   |   | executable     |
                 +----------------+   +----------------+
                         |                  |
                         | http://.../mcp   | Unix socket commands
                         v                  v

+------------------------------------------------------------------+
| openpets repo                                                     |
|                                                                  |
|  +-------------------------+        +--------------------------+  |
|  | openpets-menubar        |        | openpets CLI             |  |
|  | menu bar app executable |        | Sources/OpenPetsCLI      |  |
|  |                         |        |                          |  |
|  | - starts MCP server     |        | - notify                 |  |
|  | - starts pet host       |        | - animate                |  |
|  | - plugin menus          |        | - ping/stop/clear        |  |
|  | - app onboarding        |        | - run pet directly       |  |
|  +-----------+-------------+        +------------+-------------+  |
|              |                                   |                |
|              | imports                           | imports        |
|              v                                   v                |
|  +------------------------------------------------------------+  |
|  | OpenPetsKit local package                                  |  |
|  | Packages/OpenPetsKit                                       |  |
|  |                                                            |  |
|  | - OpenPetsHost: actual desktop pet window/runtime          |  |
|  | - OpenPetsClient: socket client used by CLI/app            |  |
|  | - PetCommand / PetNotification models                      |  |
|  | - config, paths, pet installer, bundled Starcorn pet        |  |
|  | - plugin surface + reaction types                          |  |
|  +------------------------------------------------------------+  |
+------------------------------------------------------------------+

Runtime flow:

MCP client
   |
   v
openpets-menubar MCP server
   |
   v
OpenPetsKit OpenPetsHost
   |
   v
desktop pet UI


CLI/script
   |
   v
openpets CLI
   |
   v
OpenPetsKit OpenPetsClient
   |
   v
Unix socket
   |
   v
OpenPetsKit OpenPetsHost inside openpets-menubar
   |
   v
desktop pet UI
```

Short version: `openpets` is the product repo, `openpets-menubar` and `openpets` CLI are executables inside it, and `OpenPetsKit` is the shared engine underneath both. MCP and CLI are entry points into that engine, with `OpenPetsKit` vendored as a local package under `Packages/OpenPetsKit`.
