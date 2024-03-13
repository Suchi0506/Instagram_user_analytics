CREATE DATABASE ig_clone;

USE ig_clone;

/*Users*/
CREATE TABLE users(
	id INT AUTO_INCREMENT UNIQUE PRIMARY KEY,
	username VARCHAR(255) NOT NULL,
	created_at TIMESTAMP DEFAULT NOW()
);

/*Photos*/
CREATE TABLE photos(
	id INT AUTO_INCREMENT PRIMARY KEY,
	image_url VARCHAR(355) NOT NULL,
	user_id INT NOT NULL,
	created_dat TIMESTAMP DEFAULT NOW(),
	FOREIGN KEY(user_id) REFERENCES users(id)
);

/*Comments*/
CREATE TABLE comments(
	id INT AUTO_INCREMENT PRIMARY KEY,
	comment_text VARCHAR(255) NOT NULL,
	user_id INT NOT NULL,
	photo_id INT NOT NULL,
	created_at TIMESTAMP DEFAULT NOW(),
	FOREIGN KEY(user_id) REFERENCES users(id),
	FOREIGN KEY(photo_id) REFERENCES photos(id)
);

/*Likes*/
CREATE TABLE likes(
	user_id INT NOT NULL,
	photo_id INT NOT NULL,
	created_at TIMESTAMP DEFAULT NOW(),
	FOREIGN KEY(user_id) REFERENCES users(id),
	FOREIGN KEY(photo_id) REFERENCES photos(id),
	PRIMARY KEY(user_id,photo_id)
);

/*follows*/
CREATE TABLE follows(
	follower_id INT NOT NULL,
	followee_id INT NOT NULL,
	created_at TIMESTAMP DEFAULT NOW(),
	FOREIGN KEY (follower_id) REFERENCES users(id),
	FOREIGN KEY (followee_id) REFERENCES users(id),
	PRIMARY KEY(follower_id,followee_id)
);

/*Tags*/
CREATE TABLE tags(
	id INTEGER AUTO_INCREMENT PRIMARY KEY,
	tag_name VARCHAR(255) UNIQUE NOT NULL,
	created_at TIMESTAMP DEFAULT NOW()
);

/*junction table: Photos - Tags*/
CREATE TABLE photo_tags(
	photo_id INT NOT NULL,
	tag_id INT NOT NULL,
	FOREIGN KEY(photo_id) REFERENCES photos(id),
	FOREIGN KEY(tag_id) REFERENCES tags(id),
	PRIMARY KEY(photo_id,tag_id)
);

SELECT * FROM users;
SELECT * FROM photos;
SELECT * FROM comments;
SELECT * FROM likes;
SELECT * FROM follows;
SELECT * FROM tags;
SELECT * FROM photo_tags;

#To identify the five oldest users on Instagram from the provided database.
SELECT id, username FROM users
ORDER BY created_at ASC
LIMIT 5;

#Identify users who have never posted a single photo on Instagram.
SELECT * FROM users
WHERE id NOT IN
(
SELECT user_id FROM photos
);

#A) Marketing Analysis:
#To determine the winner of the contest and provide their details to the team.
SELECT photo_id FROM likes
GROUP BY photo_id
ORDER BY COUNT(user_id) DESC
LIMIT 1;
#To retrieve the winner details
WITH MostLikedPhotos as 
(
SELECT photo_id, COUNT(user-id) AS total_likes FROM likes
GROUP BY photo-id
ORDER BY COUNT(user_id) DESC
LIMIT 1
)
SELECT u.username, u.id, p.id AS photo_id, MostLikedPhotos.total-likes FROM MostLikedPhotos
JOIN photos p ON MostLikedPhotos.photo_id= p.id
JOIN users u ON u.id= p.user_id;

#Identify and suggest the top five most commonly used hashtags on the platform.
SELECT * FROM tags;
WITH top_tags AS 
(
SELECT tag_id FROM photo_tags
GROUP BY tag_id
ORDER BY COUNT(tag_id) DESC
LIMIT 5
)
SELECT t.tag_name FROM top_tags
JOIN tags t ON t.id= top_tags.tag_id;

#Determine the day of the week when most users register on Instagram. Provide insights on when to schedule an ad campaign
SELECT dayname(created_at) AS days_of_week, COUNT(*) AS no_of_users_registers FROM users
GROUP BY dayname(created_at)
ORDER BY no_of_users_registers DESC;

#B) Investor Metrics
#Calculate the average number of posts per user on Instagram. Also, provide the total number of photos on Instagram divided by the total number of users.
SELECT COUNT (id) AS total_photos FROM photos;                                  #Total number of photos
SELECT COUNT(DISTINCT id) AS total_users FROM users;                            #Total number of users
SELECT COUNT(id)/ COUNT(DISTINCT user_id) AS avg_posts_per_user 
FROM photos;                                                                    #Photos per user

#To identify users (potential bots) who have liked every single photo on the site, as this is not typically possible for a normal user:
SELECT username, COUNT(*) AS num_likes
FROM users u 
JOIN likes l ON u.id = l.user_id
GROUP BY l.user_id
HAVING num_likes = (SELECT COUNT(*) FROM photos);
