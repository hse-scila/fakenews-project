# FakeNews

Experimental and survey screens in the latest version of FakeNews web-application.

## Screen 0: starting

This is a starting screen that is shown to a user right after FakeNews
application loading. 

When a user clicks the "Start" button, the application displays a request for access
to the information about the user's communities, wall, and friends (only for
Vkontakte). The user has the opportunity not to provide any data (one
need to uncheck all the checkboxes in the pop-up window).

### Vkontakte

![Screen 0](screenshots/screen0-vk.png)

### Facebook

![Screen 0](screenshots/screen0-fb.png)

## Screen 1: news 1

This screen displays the first news (it is always about the coronavirus).

![Screen 1](screenshots/screen1.png)

The participant evaluates if the news item is true and moves the slider, which
is initially set to position 3.5, and after clicking it takes only an integer
position from 1 to 6.

Encoding:

| Answer |  Values   | Comment     |
|--------|:---------:|-------------|
| False  | 1…3       | 1 — high confidence, 3 — low confidence |
| Truth  | 4…6       | 4 — low confidence, 6 — high confidence |

## Screen 2: news 2

Political news from our news set. It is randomly selected from the database,
taking into account the following rules:

* Must have a unique combination of three variables: _frame_, _source_ and
  _truth_.

* Should be balanced against the other news (i.e. shown as often as other news).

![Screen 2](screenshots/screen2.png)

## Screen 3: news 3

Political news from our news set.

![Screen 3](screenshots/screen3.png)

## Screen 4: news 4

Political news from our news set.

![Screen 4](screenshots/screen4.png)

## Screen 5: news 5

Political news from our news set.

![Screen 5](screenshots/screen5.png)

## Screen 6: news 6

Political news from our news set.

![Screen 6](screenshots/screen6.png)

## Screen 7: news 7

Political news from our news set.

![Screen 7](screenshots/screen7.png)

## Screen 8: news 8

Political news from our news set.

![Screen 8](screenshots/screen8.png)

## Screen 9: news 9

Political news from our news set.

![Screen 9](screenshots/screen9.png)

## Screen 10

![Screen 10](screenshots/screen10.png)

## Screen 11

![Screen 11](screenshots/screen11.png)

## Screen 12

![Screen 12](screenshots/screen12.png)

## Screen 13

![Screen 13](screenshots/screen13.png)

## Screen 14

![Screen 14](screenshots/screen14.png)

## Screen 15

![Screen 15](screenshots/screen15.png)

## Screen 16

![Screen 16](screenshots/screen16.png)

## Screen 17

![Screen 17](screenshots/screen17.png)

## Screen 18

![Screen 18](screenshots/screen18.png)

## Screen 19

![Screen 19](screenshots/screen19.png)

## Screen 20

![Screen 20](screenshots/screen20.png)

## Screen 21

![Screen 21](screenshots/screen21.png)

## Screen 22

![Screen 22](screenshots/screen22.png)

## Screen 23

![Screen 23](screenshots/screen23.png)

## Screen 24

![Screen 24](screenshots/screen24.png)

## Screen 25: the results

![Screen 25](screenshots/screen25.png)

