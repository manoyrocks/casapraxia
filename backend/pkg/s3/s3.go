package s3

import (
	"bytes"
	"fmt"
	"io"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/sirupsen/logrus"
)

// Client wraps the S3 client
type Client struct {
	svc    *s3.S3
	bucket string
	log    *logrus.Logger
}

// New creates a new S3 client
func New(bucket, region, endpoint string, log *logrus.Logger) (*Client, error) {
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(region),
	})
	if err != nil {
		return nil, fmt.Errorf("failed to create AWS session: %w", err)
	}

	svc := s3.New(sess)

	// If custom endpoint provided (e.g., minio), set it
	if endpoint != "" {
		svc.Endpoint = endpoint
		svc.Config.S3ForcePathStyle = aws.Bool(true)
	}

	return &Client{
		svc:    svc,
		bucket: bucket,
		log:    log,
	}, nil
}

// UploadAudio uploads an audio file to S3
// Returns: s3_path (key used in S3)
func (c *Client) UploadAudio(key string, data []byte, contentType string) (string, error) {
	input := &s3.PutObjectInput{
		Bucket:      aws.String(c.bucket),
		Key:         aws.String(key),
		Body:        bytes.NewReader(data),
		ContentType: aws.String(contentType),
		ServerSideEncryption: aws.String(s3.ServerSideEncryptionAes256),
	}

	_, err := c.svc.PutObject(input)
	if err != nil {
		c.log.WithError(err).WithField("key", key).Error("failed to upload audio to S3")
		return "", fmt.Errorf("failed to upload audio to S3: %w", err)
	}

	c.log.WithField("key", key).Debug("audio uploaded to S3")
	return key, nil
}

// DownloadAudio downloads an audio file from S3
func (c *Client) DownloadAudio(key string) ([]byte, error) {
	input := &s3.GetObjectInput{
		Bucket: aws.String(c.bucket),
		Key:    aws.String(key),
	}

	result, err := c.svc.GetObject(input)
	if err != nil {
		c.log.WithError(err).WithField("key", key).Error("failed to download audio from S3")
		return nil, fmt.Errorf("failed to download audio from S3: %w", err)
	}
	defer result.Body.Close()

	data, err := io.ReadAll(result.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read audio data: %w", err)
	}

	return data, nil
}

// DeleteAudio deletes an audio file from S3
func (c *Client) DeleteAudio(key string) error {
	input := &s3.DeleteObjectInput{
		Bucket: aws.String(c.bucket),
		Key:    aws.String(key),
	}

	_, err := c.svc.DeleteObject(input)
	if err != nil {
		c.log.WithError(err).WithField("key", key).Error("failed to delete audio from S3")
		return fmt.Errorf("failed to delete audio from S3: %w", err)
	}

	c.log.WithField("key", key).Debug("audio deleted from S3")
	return nil
}

// GenerateSignedURL generates a signed URL for downloading audio
func (c *Client) GenerateSignedURL(key string, expiration time.Duration) (string, error) {
	req, _ := c.svc.GetObjectRequest(&s3.GetObjectInput{
		Bucket: aws.String(c.bucket),
		Key:    aws.String(key),
	})

	url, err := req.Presign(expiration)
	if err != nil {
		c.log.WithError(err).WithField("key", key).Error("failed to generate signed URL")
		return "", fmt.Errorf("failed to generate signed URL: %w", err)
	}

	return url, nil
}

// Exists checks if an object exists in S3
func (c *Client) Exists(key string) (bool, error) {
	input := &s3.HeadObjectInput{
		Bucket: aws.String(c.bucket),
		Key:    aws.String(key),
	}

	_, err := c.svc.HeadObject(input)
	if err != nil {
		if err.Error() == "NotFound" {
			return false, nil
		}
		c.log.WithError(err).WithField("key", key).Error("failed to check if object exists")
		return false, fmt.Errorf("failed to check if object exists: %w", err)
	}

	return true, nil
}
