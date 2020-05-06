% fikri cem yilmaz
% 2017400141
% compiling: yes
% complete: yes

% artist(ArtistName, Genres, AlbumIds).
% album(AlbumId, AlbumName, ArtistNames, TrackIds).
% track(TrackId, TrackName, ArtistNames, AlbumName, [Explicit, Danceability, Energy,
%                                                    Key, Loudness, Mode, Speechiness,
%                                                    Acousticness, Instrumentalness, Liveness,
%                                                    Valence, Tempo, DurationMs, TimeSignature]).


% getArtistTracks(+ArtistName, -TrackIds, -TrackNames) 5 points
getArtistTracks(ArtistName,TrackIds,TrackNames):-artist(ArtistName,_,Z),
                                getTrackIds(Z,TrackIds,M),
                                getTrackNames(TrackIds,TrackNames,M).

% Getting Track Ids from Album Names
getTrackIds([],X,M):-append([],M,X).
getTrackIds([Z|Zs],X,M):- album(Z,_,_,A),
                        append(M,A,P),
                        getTrackIds(Zs,X,P).
                        
%Getting Track Names from Ids
getTrackNames([],Y,M):-append([],M,Y).
getTrackNames([X|Xs],Y,M):- track(X,N,_,_,_),
                            append(M,[N],T),
                        getTrackNames(Xs,Y,T).


% albumFeatures(+AlbumId, -AlbumFeatures) 5 points
albumFeatures(AlbumId,AlbumFeatures):-  getTrackIds([AlbumId],TrackIds,_),
                                        getAverage(TrackIds,AlbumFeatures).
%Gets Avarage Feature of Tracks In Albums
getAverage(TrackIds,AlbumFeatures):-    length(TrackIds,X),
                                        getSum(TrackIds,[0,0,0,0,0,0,0,0,0,0,0,0,0,0],SumList),
                                        divideAll(SumList,X,[],LastButNotLeast),
                                        selectNecessary(LastButNotLeast,AlbumFeatures).
%Didn't know you've posted. So, I've filtered on my own.
selectNecessary(X,Y):-  nth0(1,X,T0),
                        nth0(2,X,T1),
                        nth0(5,X,T2),
                        nth0(6,X,T3),
                        nth0(7,X,T4),
                        nth0(8,X,T5),
                        nth0(9,X,T6),
                        nth0(10,X,T7),
                        append([],[T0],Temp1),
                        append(Temp1,[T1],Temp2),
                        append(Temp2,[T2],Temp3),
                        append(Temp3,[T3],Temp4),
                        append(Temp4,[T4],Temp5),
                        append(Temp5,[T5],Temp6),
                        append(Temp6,[T6],Temp7),
                        append(Temp7,[T7],Y).
%Getting sum of tracks' features.
getSum([],Inital,SumList):- append([],Inital,SumList).
getSum([First|Rest],Inital,SumList):-  track(First,_,_,_,FList),
                                getOneByOne(FList,[],Inital,FinList),
                                getSum(Rest,FinList,SumList).

%Adding features to releated ones.
getOneByOne([],TempList,_,FinList):- append([],TempList,FinList).
getOneByOne([F|TrList],TempList,[S|SumList],FinList):-
                                                        TempElement is F+S,        
                                                        append(TempList,[TempElement],Temp2List),
                                                        getOneByOne(TrList,Temp2List,SumList,FinList).
%Dividing Features elements by a number.
divideAll([],_,TempList,AlbumFeatures):- append([],TempList,AlbumFeatures).
divideAll([S|SumList],L,TempList,AlbumFeatures):-       Tem is S/L,
                                                        append(TempList,[Tem],Temp2List),
                                                        divideAll(SumList,L,Temp2List,AlbumFeatures). 

% artistFeatures(+ArtistName, -ArtistFeatures) 5 points
artistFeatures(ArtistName,ArtistFeatures):- getArtistTracks(ArtistName,TrackIds,_),
                                            getAverage(TrackIds,ArtistFeatures).


% trackDistance(+TrackId1, +TrackId2, -Score) 5 points

trackDistance(TrackId1,TrackId2,Score):- track(TrackId1,_,_,_,Feature1),
                                        track(TrackId2,_,_,_,Feature2),
                                        selectNecessary(Feature1,NFeature1),
                                        selectNecessary(Feature2,NFeature2),
                                        squareDistance(NFeature1,NFeature2,0,S),
                                        Score is sqrt(S).

%Finding euclidian distance withoyt square root.
squareDistance([],[],Temp,SquareTotal):- SquareTotal is Temp.
squareDistance([N1|NFeature1],[N2|NFeature2],Temp,SquareTotal):-    Temp2 is (N1-N2),
                                                                    Temp4 is Temp2*Temp2,
                                                                    Temp3 is Temp+Temp4,
                                                                    squareDistance(NFeature1,NFeature2,Temp3,SquareTotal).

% albumDistance(+AlbumId1, +AlbumId2, -Score) 5 points

albumDistance(AlbumId1,AlbumId2,Score):- albumFeatures(AlbumId1,NFeature1),
                                        albumFeatures(AlbumId2,NFeature2),
                                        squareDistance(NFeature1,NFeature2,0,S),
                                        Score is sqrt(S).

% artistDistance(+ArtistName1, +ArtistName2, -Score) 5 points

artistDistance(ArtistName1,ArtistName2,Score):- artistFeatures(ArtistName1,NFeature1),
                                                artistFeatures(ArtistName2,NFeature2),
                                                squareDistance(NFeature1,NFeature2,0,S),
                                                Score is sqrt(S).

% findMostSimilarTracks(+TrackId, -SimilarIds, -SimilarNames) 10 points
findMostSimilarTracks(TrackId,SimilarIds,SimilarNames):-findall(X,track(X,_,_,_,_),Y),
                                                        addThemToList(Y,TrackId,[],TrioList),
                                                        done(TrioList,[],[],SimilarIds,SimilarNames).
%Adds the songs from all tracks, when list reaches the 31 member, sorts them and deletes the last one.
addThemToList([],_,TempList,TrioList):-     
                                            append([],TempList,TrioList).
addThemToList([Y|RestY],TrackId,TempList,TrioList):- 
                                            (Y==TrackId ->addThemToList(RestY,TrackId,TempList,TrioList);
                                            trackDistance(TrackId,Y,Score),
                                            append(TempList,[[Score|Y]],Temp2List),
                                            length(Temp2List,R),
                                             (R >= 30 -> 
                                             sort(Temp2List,STrioList),
                                             findFirstThirty(STrioList,0,[],FinList),
                                             addThemToList(RestY,TrackId,FinList,TrioList);
                                             addThemToList(RestY,TrackId,Temp2List,TrioList)
                                            )
                                             ).
%Getting first 30 elements of List.
findFirstThirty(_,29,TempList,FinList):- append([],TempList,FinList).
findFirstThirty(TrioList,Count,TempList,FinList):-  Count < 29,
                                                    Count2 is Count+1,
                                                    nth0(Count,TrioList,X),
                                                    append(TempList,[X],Temp2List),
                                                    findFirstThirty(TrioList,Count2,Temp2List,FinList).
%Gets the song names from their ids.
done([],TempList,Temp2List,SimilarIds,SimilarNames):-   append([],TempList,SimilarIds),
                                                        append([],Temp2List,SimilarNames).
done([[_|FinList]|Rest],TempList,Temp2List,SimilarIds,SimilarNames):- append(TempList,[FinList],Temp3List),
                                                                        track(FinList,T,_,_,_),
                                                                        append(Temp2List,[T],Temp4List),
                                                                        done(Rest,Temp3List,Temp4List,SimilarIds,SimilarNames).
% findMostSimilarAlbums(+AlbumId, -SimilarIds, -SimilarNames) 10 points
findMostSimilarAlbums(AlbumId,SimilarIds,SimilarNames):-findall(X,album(X,_,_,_),Y),
                                                        addThemToList2(Y,AlbumId,[],TrioList),
                                                        done2(TrioList,[],[],SimilarIds,SimilarNames).
%Same as addThemToList, except this one for album.
addThemToList2([],_,TempList,TrioList):- append([],TempList,TrioList).
addThemToList2([Y|RestY],AlbumId,TempList,TrioList):- 
                                            (Y==AlbumId ->addThemToList2(RestY,AlbumId,TempList,TrioList);
                                            albumDistance(AlbumId,Y,Score),
                                            append(TempList,[[Score|Y]],Temp2List),
                                            length(Temp2List,R),
                                             (R >= 30 ->
                                             sort(Temp2List,STrioList),
                                             findFirstThirty(STrioList,0,[],FinList),
                                             addThemToList2(RestY,AlbumId,FinList,TrioList);
                                             addThemToList2(RestY,AlbumId,Temp2List,TrioList)
                                            )
                                             ).
%Same as done, except this one for album.
done2([],TempList,Temp2List,SimilarIds,SimilarNames):-   append([],TempList,SimilarIds),
                                                        append([],Temp2List,SimilarNames).
done2([[_|FinList]|Rest],TempList,Temp2List,SimilarIds,SimilarNames):- append(TempList,[FinList],Temp3List),
                                                                        album(FinList,T,_,_),
                                                                        append(Temp2List,[T],Temp4List),
                                                                        done2(Rest,Temp3List,Temp4List,SimilarIds,SimilarNames).

% findMostSimilarArtists(+ArtistName, -SimilarArtists) 10 points

findMostSimilarArtists(ArtistName,SimilarArtists):-findall(X,artist(X,_,_),Y),
                                                        addThemToList3(Y,ArtistName,[],TrioList),
                                                        done3(TrioList,[],SimilarArtists).
%Same as addThemToList, except this one for artist.
addThemToList3([],_,TempList,TrioList):- append([],TempList,TrioList).
addThemToList3([Y|RestY],ArtistName,TempList,TrioList):- 
                                            (Y==ArtistName ->addThemToList3(RestY,ArtistName,TempList,TrioList);
                                            artistDistance(ArtistName,Y,Score),
                                            append(TempList,[[Score|Y]],Temp2List),
                                            length(Temp2List,R),
                                             (R >= 30 ->
                                             sort(Temp2List,STrioList),
                                             findFirstThirty(STrioList,0,[],FinList),
                                             addThemToList3(RestY,ArtistName,FinList,TrioList);
                                             addThemToList3(RestY,ArtistName,Temp2List,TrioList)
                                            )).
%Same as done, except this one for artist.
done3([],TempList,SimilarArtists):-  append([],TempList,SimilarArtists).
done3([[_|FinList]|Rest],TempList,SimilarArtists):-     append(TempList,[FinList],Temp3List),
                                                         done3(Rest,Temp3List,SimilarArtists).

% filterExplicitTracks(+TrackList, -FilteredTracks) 5 points
filterExplicitTracks(TrackList,FilteredTracks):- filter(TrackList,[],FilteredTracks).

%Filters Track according to explicity(?)
filter([],TempList,FilteredTracks):- append([],TempList,FilteredTracks).
filter([T|TrackList],TempList,FilteredTracks):- track(T,_,_,_,[X|_]),
                                                (X =:= 0 -> 
                                                append(TempList,[T],Temp2List);
                                                append(TempList,[],Temp2List)),
                                                filter(TrackList,Temp2List,FilteredTracks).

% getTrackGenre(+TrackId, -Genres) 5 points

getTrackGenre(TrackId,Genres):- track(TrackId,_,X,_,_),
                                findGenres(X,[],Genres).
%Finds artists and concatanate their genres.
findGenres([],TempGenre,Genres):-append([],TempGenre,Genres).
findGenres([X|R],TempGenre,Genres):-artist(X,G,_),
                                    list_to_set(TempGenre,STempGenre),
                                    list_to_set(G,SG),
                                    union(STempGenre,SG,Temp),
                                    findGenres(R,Temp,Genres).
% discoverPlaylist(+LikedGenres, +DislikedGenres, +Features, +FileName, -Playlist) 30 points

discoverPlaylist(LikedGenres,DislikedGenres,Features,FileName,Playlist):-   findall(X,track(X,_,_,_,_),Y),
                                                                    filter(LikedGenres,DislikedGenres,Y,[],Filtered),
                                                                    findSortDistance(Filtered,Features,[],Sorted),
                                                                    findDistnaceOfThem(Sorted,[],Dis),
                                                                    done(Sorted,[],[],P,R),
                                                                    findArtistOfThem(P,[],Ar),
                                                                    append([],P,Playlist),
                                                                    open(FileName,write,OS),
                                                                    write(OS,Playlist),
                                                                    nl(OS),
                                                                    write(OS,R),
                                                                    nl(OS),
                                                                    write(OS,Ar),
                                                                    nl(OS),
                                                                    write(OS,Dis),
                                                                    close(OS).

%Finds Artist of List.
findArtistOfThem([],Temps,ArtistNames):-append(Temps,[],ArtistNames).
findArtistOfThem([Song|SongIds],Temps,ArtistNames):-track(Song,_,Name,_,_),
                                                    append(Temps,[Name],Temps2),
                                                    findArtistOfThem(SongIds,Temps2,ArtistNames).
%Finds Distance of List.
findDistnaceOfThem([],TempList,FinList):- append(TempList,[],FinList).
findDistnaceOfThem([[Score|_]|Rest],TempList,Fin):-
                                                    append(TempList,[Score],Temp2List),
                                                findDistnaceOfThem(Rest,Temp2List,Fin).
%While looking filtered track List, sorts them every time and dismember 31st one.
findSortDistance([],_,TempList,Final):- append(TempList,[],Final).
findSortDistance([Filter|Filtered],Features,TempList,Final):-
                                            track(Filter,_,_,_,Feat),
                                            selectNecessary(Feat,Feature1),
                                            squareDistance(Feature1,Features,0,Score),
                                            Score2 is sqrt(Score),
                                            append(TempList,[[Score2|Filter]],Temp2List),
                                            length(Temp2List,R),
                                             (R >= 30 -> 
                                             sort(Temp2List,STrioList),
                                             findFirstThirty2(STrioList,0,[],FinList),
                                             findSortDistance(Filtered,Features,FinList,Final);
                                             findSortDistance(Filtered,Features,Temp2List,Final)
                                            ).
%Actually same code but I've got different results so I'd to divide them to two parts. 
findFirstThirty2(_,30,TempList,FinList):- append([],TempList,FinList).
findFirstThirty2(TrioList,Count,TempList,FinList):-  Count < 30,
                                                    Count2 is Count+1,
                                                    nth0(Count,TrioList,X),
                                                    append(TempList,[X],Temp2List),
                                                    findFirstThirty2(TrioList,Count2,Temp2List,FinList).

%Filters them according to likes and dislikes.
filter(_,_,[],TempList,FinList):-append(TempList,[],FinList).
filter(LikedGenres,DislikedGenres,[Song|SongList],TempList,FinList):- 
                                                                getTrackGenre(Song,SongGenres),
                                                                (isLiked(LikedGenres,SongGenres)->
                                                                (isNotDisliked(DislikedGenres,SongGenres)->
                                                                append(TempList,[Song],Temp2List),
                                                                filter(LikedGenres,DislikedGenres,SongList,Temp2List,FinList);
                                                                filter(LikedGenres,DislikedGenres,SongList,TempList,FinList));
                                                                filter(LikedGenres,DislikedGenres,SongList,TempList,FinList)).
%Look for given track contains liked genres.
isLiked([],_):-false.
isLiked([LikedGenre|Genres],SongGenres):-(checkList(LikedGenre,SongGenres)->
                                        true;
                                        isLiked(Genres,SongGenres)).
%Look for given track not contains disliked genres.
isNotDisliked([],_):- true.
isNotDisliked([DislikedGenre|Genres],SongGenres):-(checkList(DislikedGenre,SongGenres)->
                                        false;
                                        isNotDisliked(Genres,SongGenres)).
%checks the genre list.
checkList(_,[]):-false.
checkList(Y,[Genre|Genres]):-   (sub_string(Genre,_,_,_,Y)->
                                true;
                                checkList(Y,Genres)).