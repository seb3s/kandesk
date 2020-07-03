## v0.15.0 - 2020-07-03

  - New modal: share a board with users, grant users access to functionalities according to defined rights


## v0.14.1 - 2020-06-18

  - Set boards dropdown menu to hoverable style
  - Limit nested dropdown menus in height


## v0.14.0 - 2020-06-17

  - New feature: move a column to another board
  - New feature: duplicate a column
  - Add modal position to assigns to keep track of draggings
  - Upgrade phoenix_live_view to 0.13.3


## v0.13.1 - 2020-05-27

  - Upgrade phoenix_live_view to 0.13.2


## v0.13.0 - 2020-05-14

  - Optimization: avoid updating tags when none has changed
  - Use liveview components to reduce size of updates sent on the wire


## v0.12.1 - 2020-05-06

  - Better css for columns to be able to customize with a fixed number of columns adjusted to screen width


## v0.12.0 - 2020-05-05

  - Add my account page with name & change password
  - Better favicon


## v0.11.0 - 2020-04-27

  - Upgrade phoenix to 1.5.x. Add phoenix_live_dashboard.


## v0.10.2 - 2020-04-20

  - Dashboard - Fix body scroll behaviour after creating a new board
  - Revert back to raising an error in case of hacking as it is the correct way of doing it


## v0.10.1 - 2020-04-18

  - Fix when board descr is nil


## v0.10.0 - 2020-04-18

  - Add column visibility
  - Add board custom style hack
  - Fix word overflowing in tasks
  - Fix some user rights


## v0.9.0 - 2020-04-15

  - Add security checks to fight against falsification of phx-xx attributes
  - Fix delete board when board is shared
  - Create SQL stored procedures with ecto.migrate


## v0.8.2 - 2020-04-11

  - Board page - While changing board with the new board button, move_column? rights is not taken into account
  - Board page - Improve tag checkboxes to be able to click on span element directly


## v0.8.1 - 2020-04-10

  - Remove local optimizations via variables that impacts liveview diff optimizations


## v0.8.0 - 2020-04-10

  - Board page - Add a button to navigate between boards
  - Board page - Add a button to add a card on top of list with a menu for other actions
  - Board page - Increase columns density a little bit


## v0.7.2 - 2020-04-08

  - Keep column scrollbar position when updating tasks
  - Upgrade to liveview 0.11.0


## v0.7.1 - 2020-04-08

  - Fix multi lines display for board description


## v0.7.0 - 2020-04-07

  - Add tags management


## v0.6.0 - 2020-04-02

  - Dashboard - Add pubsub to boards events
  - Add multi-user access to boards with rights management


## v0.5.0 - 2020-03-30

  - Board page - Add pubsub when viewing a board to share a common view accross users / browsers


## v0.4.0 - 2020-03-27

  - Dashboard - Sort boards by their name
  - Board page - Add board horizontal scrolling while dragging mouse
  - Board page - Columns are now sortable via their headers
  - Upgrade to liveview 0.10.0


## v0.3.1 - 2020-03-25

  - Fix missing ids for proper hook triggering, to correct the columns & tasks sortering failure


## v0.3.0 - 2020-03-24

  - Add delete task
  - Add delete board
  - Add edit board
  - Add kandesk logo to pages
  - UI improvements


## v0.2.0 - 2020-03-23

  - New login panel with a better UI and kandesk logo


## v0.1.0 - 2020-03-23

  - Initial version with boards, columns and tasks, only viewable by its creator