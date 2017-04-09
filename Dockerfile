FROM python:3-onbuild
EXPOSE 5953
CMD ["python", "./pyzorsocket.py", "0.0.0.0", "5953"]
