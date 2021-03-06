<b>MovieViewer</b> is a movies app using the [The Movie Database API](http://docs.themoviedb.apiary.io/#).

Time spent: ~26 hours spent in total

## User Stories

The following **required** functionality is complete:

- [x] User can view a list of movies currently playing in theaters from The Movie Database.
- [x] Poster images are loaded using the UIImageView category in the AFNetworking library.
- [x] User sees a loading state while waiting for the movies API.
- [x] User can pull to refresh the movie list.

The following **optional** features are implemented:

- [x] User sees an error message when there's a networking error.
- [x] Movies are displayed using a CollectionView instead of a TableView.
- [x] User can search for a movie.
- [x] All images fade in as they are loading.
- [x] Customize the UI.

The following **additional** features are implemented:

- [x] User can choose between TableView and CollectionView
- [x] User can also view Top Rated Movies using the TabBarController
- [x] User could view movie descriptions that are displayed on a separate ViewController
- [x] Animations for movie descriptions
- [x] .sizeToFit() used for titles to occupy space needed, and adjustsFontSizeToFitWidth for descriptions to fit the allocated space


## Video Walkthrough 

Here's a walkthrough of implemented user stories:

![Walkthrough](MovieDatabaseFinal.gif)
 

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes
I felt that one of the most challenging things about this app was trying to figure out how to properly make the network error function. In order to do so, you must understand how it obtains information from the API, which was something I had to look at for a while. Customizing was also quite difficult, as well as the installing of the CocoaPods. It was a super fun app to build, nonetheless!

## License

    Copyright [2016] [Isis Moran]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.


# Project 2 - <b>MovieViewer</b>

<b>MovieViewer</b> is a movies app displaying box office and top rental DVDs using [The Movie Database API](http://docs.themoviedb.apiary.io/#).

Time spent: ~15 hours spent in total

## User Stories

The following **required** functionality is completed:

- [x] User can view movie details by tapping on a cell.
- [x] User can select from a tab bar for either **Now Playing** or **Top Rated** movies.
- [x] Customize the selection effect of the cell.

The following **optional** features are implemented:

- [x] For the large poster, load the low resolution image first and then switch to the high resolution image when complete.
- [x] Customize the navigation bar.

The following **additional** features are implemented:

- [x] User can choose between TableView and CollectionView
- [x] User can see more movie details - such as genre, runtime, and taglines (if available)


## Video Walkthrough 

Here's a walkthrough of implemented user stories:

![Walkthrough](MovieDatabase6.gif)

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

This week, I definitely struggled with passing information from one view controller to the next (using a segue). Also, for last weeks' assignment, I created the tab bar controller using the storyboard, so implementing a programmatically-created tab bar was challenging, since I had to backtrack and reimplement everything. 

## License

    Copyright [2016] [Isis Moran]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

